**Terminal e TTY**

> como os bytes vão do teclado até o `read()`

Um terminal, para um programa Unix, é um **dispositivo** (um arquivo em `/dev`) que conecta um usuário a processos: o que o usuário digita vira bytes que os processos leem, e o que os processos escrevem vira caracteres na tela. Entre os dois lados existe uma camada do kernel, a **line discipline**, que processa esses bytes segundo a configuração `termios`. É por isso que um simples `read(STDIN_FILENO, ...)` se comporta de forma diferente conforme o terminal está configurado

**Os nomes**

- **Terminal**: originalmente um equipamento físico (teclado + tela, como o VT100) ligado ao computador por um cabo serial
- **TTY** (teletypewriter): o nome Unix para o dispositivo de terminal no kernel e o subsistema que os gerencia. Hoje é usado para qualquer terminal: console, porta serial ou pseudoterminal
- **Terminal emulator**: um programa comum (Alacritty, Kitty, GNOME Terminal, iTerm2, Terminal.app) que faz o papel do terminal físico: lê o teclado, desenha caracteres na janela e interpreta escape sequences
- **PTY** (pseudoterminal): um par de dispositivos criado pelo kernel para que um programa (o emulator, o `ssh`, o `tmux`) faça o papel do terminal físico
	- **master** (ou lado do terminal): aberto pelo emulator. O que ele escreve aqui é "o que o usuário digitou"
	- **slave** (ou lado do processo): aparece como `/dev/pts/N` (Linux) ou `/dev/ttysNNN` (macOS). É o stdin/stdout/stderr do shell e dos programas
- **Terminal driver**: o código do kernel que implementa os dispositivos de terminal (PTY, serial, console)
- **Line discipline**: a camada do terminal driver que fica entre o hardware/PTY e os processos e aplica o `termios`: edição de linha, echo, sinais, conversões de `\r`/`\n`. No Linux, a padrão se chama `N_TTY`

**O caminho dos bytes**

```text
                            ESPAÇO DE USUÁRIO
┌────────────────────┐                           ┌───────────────────────┐
│ Terminal emulator  │                           │ seu programa          │
│ (lê teclado, ─────────── write(master) ─┐      │ read(STDIN_FILENO)    │
│  desenha tela) ◄──────── read(master) ──┼─┐    │ write(STDOUT_FILENO)  │
└────────────────────┘                    │ │    └───────▲───────────┬───┘
══════════════════════════════════════════│═│════════════│═══════════│══
                                 KERNEL   ▼ │            │           ▼
                         ┌────────────────────────────────────────────────┐
                         │ PTY master          line discipline     PTY slave │
                         │   entrada ──► c_iflag ─► c_lflag/c_cc ─► fila ─┘ │
                         │                           │ echo                 │
                         │   saída  ◄── c_oflag ◄────┴──────── write() ◄───│
                         └────────────────────────────────────────────────┘
```

Passo a passo ao apertar `a`:

1. O emulator recebe a tecla do sistema gráfico e escreve o byte `a` no **master**
2. O kernel passa o byte pela line discipline: `c_iflag` (conversões), depois `c_lflag`/`c_cc` (é um caractere especial? gera sinal? vai para o buffer de linha?)
3. Se `ECHO` estiver ligado, a line discipline manda uma cópia do `a` de volta para o lado de **saída**, e o emulator a desenha. Quem mostra o que você digita é o kernel, e não o seu programa nem o emulator
4. Em modo canônico, o `a` fica guardado no buffer de linha. Só quando chega o `\n` a linha inteira vai para a fila de leitura e o `read()` do seu programa retorna (ver `canonical-mode.md`)
5. Quando o programa faz `write(STDOUT_FILENO, "oi\n", 3)`, os bytes passam por `c_oflag` (o `\n` vira `\r\n`) e chegam ao master, de onde o emulator os lê e desenha

> O diagrama é conceitual. Emulator, `ssh`, `tmux` e o seu programa rodam em espaço de usuário. PTY, line discipline e as filas ficam no kernel. Em um terminal serial real, o lugar do PTY master é ocupado pelo driver da porta serial (UART), e o terminal físico do outro lado do cabo faz o papel do emulator

**Por que o read() é afetado**

O `read()` em um fd de terminal não lê "do teclado": lê da **fila de saída da line discipline**. O que estará nessa fila, e quando, depende do `termios`:

```c
char buf[100];
ssize_t n = read(STDIN_FILENO, buf, sizeof(buf));
```

| Configuração | O `read()` retorna... | `buf` contém |
|--------------|----------------------|--------------|
| canônico (padrão) | depois do Enter | `"pato\n"`, já com Backspaces aplicados |
| não canônico, `VMIN=1` | a cada tecla | `"p"` |
| `ICRNL` desligado | — | Enter chega como `'\r'` (13) |
| `ISIG` ligado | `Ctrl+C` nunca chega | o processo recebe `SIGINT` |

- O mesmo código, sem nenhuma alteração, lê linhas inteiras ou teclas individuais: quem decide é a configuração do terminal, aplicada pelo kernel antes do `read()`
- Com stdin redirecionado (`./app < arquivo.txt` ou `echo oi | ./app`), não existe line discipline no caminho e o `read()` devolve os bytes do arquivo/pipe crus

**Descobrindo o terminal**

```c
if (isatty(STDIN_FILENO)) {
  printf("terminal: %s\n", ttyname(STDIN_FILENO)); // /dev/pts/3 ou /dev/ttys002
}
```

```bash
tty            # nome do terminal do shell atual
ls -l /proc/$$/fd   # Linux: 0, 1 e 2 apontam para /dev/pts/N
```

- `/dev/tty` é um apelido especial para o **terminal de controle** do processo atual, seja ele qual for. Útil para pedir uma senha mesmo quando stdin e stdout estão redirecionados

**Terminal de controle e sessões**

- Cada sessão (normalmente um shell e seus filhos) tem um terminal de controle. Os sinais de teclado (`SIGINT`, `SIGTSTP`) gerados pela line discipline vão para o **grupo de processos em foreground** daquele terminal, e não para um processo específico
- É por isso que `Ctrl+C` interrompe o programa rodando, e não o shell: o shell coloca o programa em foreground com `tcsetpgrp()`
- Processos em background que tentam ler do terminal recebem `SIGTTIN` (e param). Com `TOSTOP` ligado, escrever também gera `SIGTTOU` (ver `local-flags.md`)

> Os PTYs são criados com `posix_openpt()`, `grantpt()`, `unlockpt()` e `ptsname()` (ou `openpty()`/`forkpty()`, extensões disponíveis no Linux e no macOS). É exatamente o que o emulator faz ao abrir uma janela: cria um PTY, faz `fork()`, coloca o slave como fd 0, 1 e 2 do filho e executa o shell
