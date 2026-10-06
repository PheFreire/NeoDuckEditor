**Local flags**

> campo `c_lflag` de `struct termios`

O `c_lflag` controla o comportamento que o usuário percebe diretamente no terminal: se a entrada é por linha (`ICANON`), se o que é digitado aparece na tela (`ECHO`), se `Ctrl+C` e `Ctrl+Z` geram sinais (`ISIG`) e se as teclas de edição estendidas funcionam (`IEXTEN`). É o campo mais alterado em programas interativos

```text
byte (já passou por c_iflag)
   │
   ▼
ISIG?    é VINTR/VQUIT/VSUSP? → envia sinal ao grupo em foreground, descarta o byte
   │
ICANON?  sim → buffer de linha com edição (VERASE, VKILL...), libera no \n ou VEOF
         não → vai direto para a fila, controlado por VMIN/VTIME
   │
ECHO?    copia o byte para a saída (tela)
   │
   ▼
fila de leitura → read()
```

**ECHO**

- Ligada (padrão): a line discipline envia de volta para a tela uma cópia de cada byte recebido. É o kernel que mostra o que você digita, e não o programa nem o emulator
- Desligada: nada aparece ao digitar. Usado para senhas (ver `examples.md`) e em raw mode, onde o programa decide o que desenhar
- O echo passa pelo processamento de saída (`c_oflag`), então em raw mode um Enter ecoado vira só `\r`

**ECHOE, ECHOK, ECHONL, ECHOCTL, ECHOKE**

Ajustes finos do echo, relevantes no modo canônico:

- `ECHOE`: com `ICANON`, o `VERASE` (Backspace) apaga o caractere na tela, enviando `\b \b` (volta, espaço, volta). Desligada, o caractere some do buffer, mas continua visível
- `ECHOK`: com `ICANON`, após o `VKILL` (`Ctrl+U`), envia uma nova linha
- `ECHOKE` (não POSIX): o `VKILL` apaga visualmente a linha inteira, em vez de só pular de linha
- `ECHONL`: com `ICANON`, ecoa o `\n` mesmo que `ECHO` esteja desligado. Útil ao ler senhas: o usuário vê o Enter mas não a senha
- `ECHOCTL` (não POSIX): mostra caracteres de controle como `^C`, `^D`, em vez do byte cru. É por isso que aparece `^C` na tela ao interromper um programa

**ICANON**

- Ligada (padrão): modo canônico, com buffer e edição de linha. O `read()` só retorna com uma linha completa (ver `canonical-mode.md`)
- Desligada: modo não canônico. Os bytes vão direto para a fila e o `read()` segue `VMIN`/`VTIME` (ver `raw-mode.md`)
- Os caracteres de edição (`VERASE`, `VKILL`, `VEOF`, `VEOL`) **só** têm efeito com `ICANON` ligada. Desligada, chegam ao programa como bytes comuns (Backspace = 127, `Ctrl+D` = 4)

**ISIG**

- Ligada (padrão): os caracteres `VINTR`, `VQUIT` e `VSUSP` geram sinais em vez de chegar ao programa:

| Tecla | `c_cc` | Sinal | Efeito padrão |
|-------|--------|-------|---------------|
| `Ctrl+C` | `VINTR` | `SIGINT` | termina o processo |
| `Ctrl+\` | `VQUIT` | `SIGQUIT` | termina e gera core dump |
| `Ctrl+Z` | `VSUSP` | `SIGTSTP` | suspende (o shell retoma com `fg`) |
| `Ctrl+T` (macOS) | `VSTATUS` | `SIGINFO` | mostra o status do processo |

- O sinal vai para todo o **grupo de processos em foreground** do terminal (ver `terminal-and-tty.md`)
- Desligada: os bytes chegam ao `read()` (`3`, `28`, `26`). O programa só pode ser interrompido se tratar esses bytes. Editores desligam para usar `Ctrl+C`/`Ctrl+Z` como comandos
- Se a ideia é só personalizar o que acontece com `Ctrl+C`, prefira manter `ISIG` e tratar o sinal com `sigaction`

**IEXTEN**

- Liga o processamento **estendido**, definido por cada implementação. Na prática, habilita:
	- `VLNEXT` (`Ctrl+V`): o próximo caractere é inserido literalmente, sem função especial
	- `VWERASE` (`Ctrl+W`): apaga a última palavra
	- `VREPRINT` (`Ctrl+R`): reescreve a linha atual
	- `VDISCARD` (`Ctrl+O`, macOS): descarta a saída até o próximo `Ctrl+O`
- Desligada em raw mode: senão, `Ctrl+V` (e `Ctrl+O` no macOS) seriam consumidos pela line discipline e nunca chegariam ao programa

**Outras**

- `NOFLSH`: não descarta as filas de entrada e saída quando um sinal (`SIGINT`, `SIGQUIT`, `SIGTSTP`) é gerado pelo teclado. Por padrão, `Ctrl+C` também descarta o que estava digitado
- `TOSTOP`: um processo em **background** que tentar escrever no terminal recebe `SIGTTOU` e é suspenso. Desligada por padrão, por isso jobs em background (`./app &`) podem misturar a saída na tela
- `PENDIN`, `FLUSHO`: estado interno (não POSIX), indicam linha pendente de reimpressão e saída sendo descartada

> Para senhas: desligue só `ECHO` (e ligue `ECHONL`), mantendo `ICANON` e `ISIG`, assim o usuário ainda pode apagar com Backspace, confirmar com Enter e cancelar com `Ctrl+C`. Para editores e jogos: desligue `ECHO`, `ICANON`, `ISIG` e `IEXTEN`
