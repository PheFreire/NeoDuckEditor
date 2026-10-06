**Raw mode**

> modo não canônico e raw mode

Raw mode é a configuração em que o terminal entrega ao programa **cada byte exatamente como foi recebido, assim que chega**: sem esperar o Enter, sem mostrar o que foi digitado, sem transformar `\r` em `\n`, sem gerar sinais com `Ctrl+C`. É o modo usado por editores (vim, nano), `less`, `top`, jogos de terminal e qualquer interface que reaja a teclas individuais

**Três níveis**

| Modo | O que muda | `read()` |
|------|------------|----------|
| canônico (padrão) | linha editável, echo, sinais, conversões | retorna após o Enter |
| não canônico | só `ICANON` desligado (às vezes `ECHO` também) | retorna por byte, conforme `VMIN`/`VTIME`. Ctrl+C ainda gera `SIGINT`, Enter ainda vira `\n` |
| raw | todo processamento desligado: entrada, saída, sinais, tamanho do caractere | bytes crus: Ctrl+C chega como `3`, Enter como `13` |

- **Não canônico** e **raw** não são sinônimos: desligar o `ICANON` só acaba com o buffer de linha. Os outros processamentos (`ISIG`, `ICRNL`, `IXON`, `OPOST`...) continuam ativos até serem desligados um por um
- "Raw" não é uma flag: é o nome para a combinação de desligar praticamente todas

**Recebendo teclas sem esperar o Enter** (não canônico)

```c
struct termios orig, t;
tcgetattr(STDIN_FILENO, &orig);   // guarda a configuração original
t = orig;

t.c_lflag &= ~(ICANON | ECHO);    // sem buffer de linha, sem echo
t.c_cc[VMIN]  = 1;                // read() espera pelo menos 1 byte
t.c_cc[VTIME] = 0;                // sem timeout
tcsetattr(STDIN_FILENO, TCSAFLUSH, &t);

char c;
read(STDIN_FILENO, &c, 1);        // retorna assim que uma tecla é apertada

tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);  // restaura
```

`t.c_lflag &= ~(ICANON | ECHO);`, parte por parte:

- `c_lflag`: o campo de modos locais, um inteiro em que cada bit é uma opção (ver `local-flags.md`)
- `ICANON`: o bit que liga o modo canônico (buffer de linha e edição)
- `ECHO`: o bit que faz a line discipline mostrar na tela cada caractere recebido
- `ICANON | ECHO`: o OR cria uma máscara com exatamente esses dois bits ligados
- `~(...)`: inverte a máscara: todos os bits ligados, **exceto** esses dois
- `&=`: um AND com essa máscara zera os dois bits em `c_lflag` e preserva todos os outros (`ISIG`, `IEXTEN`...)
- Detalhes das operações em `terminal-attributes.md`

**VMIN e VTIME**

Com `ICANON` desligado, `c_cc[VMIN]` e `c_cc[VTIME]` decidem quando o `read()` retorna:

| `VMIN` | `VTIME` | Comportamento do `read()` |
|--------|---------|---------------------------|
| `> 0` | `0` | bloqueia até chegarem `VMIN` bytes |
| `0` | `> 0` | espera até `VTIME` décimos de segundo. Retorna 1 byte se chegar, ou `0` se o tempo acabar |
| `> 0` | `> 0` | bloqueia até o primeiro byte. Depois retorna quando chegarem `VMIN` bytes ou passar `VTIME` décimos sem chegar nenhum novo |
| `0` | `0` | não bloqueia: retorna o que houver, ou `0` imediatamente |

- `VTIME` é em **décimos** de segundo (`VTIME = 10` → 1 segundo), e cabe em um `cc_t` (máximo 255 → 25,5 s)
- `VMIN=0`/`VTIME=1` é muito usado em editores: o `read()` retorna a cada 0,1 s mesmo sem tecla, permitindo atualizar a tela e distinguir um `ESC` sozinho do início de uma sequência de seta (ver `examples.md`)
- O `read()` pode retornar menos que `VMIN` se for interrompido por um sinal (`EINTR`)

**Raw mode completo**

```c
struct termios raw = orig;

raw.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
raw.c_oflag &= ~OPOST;
raw.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
raw.c_cflag &= ~(CSIZE | PARENB);
raw.c_cflag |= CS8;
raw.c_cc[VMIN]  = 1;
raw.c_cc[VTIME] = 0;

tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
```

| Campo | Flag desligada | Efeito de desligar |
|-------|----------------|--------------------|
| `c_iflag` | `ICRNL` | Enter chega como `\r` (13), e `Ctrl+M` deixa de ser igual a `Ctrl+J` |
| | `IXON` | `Ctrl+S`/`Ctrl+Q` chegam como bytes (19/17) em vez de pausar a saída |
| | `INLCR`, `IGNCR` | nenhuma outra conversão ou descarte de `\r`/`\n` |
| | `BRKINT`, `IGNBRK`, `PARMRK`, `ISTRIP` | break não gera sinal, bytes não são marcados nem cortados para 7 bits |
| `c_oflag` | `OPOST` | `\n` deixa de virar `\r\n`. O programa precisa escrever `\r\n` |
| `c_lflag` | `ECHO`, `ECHONL` | nada é mostrado automaticamente |
| | `ICANON` | sem buffer de linha |
| | `ISIG` | `Ctrl+C`/`Ctrl+Z`/`Ctrl+\` chegam como bytes (3/26/28), sem sinais |
| | `IEXTEN` | `Ctrl+V` (e `Ctrl+O` no macOS) chegam como bytes em vez de serem interpretados |
| `c_cflag` | `CSIZE`, `PARENB` → `CS8` | caracteres de 8 bits, sem paridade |

**cfmakeraw()**

```c
struct termios raw = orig;
cfmakeraw(&raw);
tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
```

- Aplica essas mesmas alterações na `struct` (não chama `tcsetattr`, só modifica a cópia)
- **Não é POSIX**: é uma extensão BSD, presente na glibc (Linux) e no macOS, mas pode faltar em outros sistemas. No Linux, pode exigir `#define _DEFAULT_SOURCE` antes dos includes quando compilado com `-std=c17`
- A glibc também define `VMIN=1` e `VTIME=0`. Não conte com isso em outros sistemas e defina os dois explicitamente
- Desliga **tudo**, inclusive `ISIG`: se o programa não tratar o byte `3` (`Ctrl+C`), não há como interrompê-lo pelo teclado

**Armadilhas**

- Sem `OPOST`, `printf("linha\n")` move o cursor para baixo **sem voltar para a coluna 0**, criando o efeito "escada". Escreva `\r\n` em raw mode
- Sem `ISIG`, um bug que trava o programa em um laço deixa o terminal sem saída pelo `Ctrl+C`. Durante o desenvolvimento, mantenha uma tecla de saída ou use `kill` de outro terminal
- Se o programa terminar sem restaurar a configuração original, o shell fica em raw mode: nada aparece ao digitar e o Enter não funciona (ver `terminal-restoration.md`)
- Teclas especiais (setas, F1, Home) não são um byte: chegam como sequências (`\x1b[A` para seta para cima) que o programa precisa interpretar

> O raw mode só muda o processamento dos bytes. Ele não limpa a tela, não esconde o cursor e não muda para a "tela alternativa" usada por editores. Essas coisas são escape sequences enviadas com `write()` (`\x1b[?1049h`, `\x1b[?25l`) e precisam ser desfeitas separadamente na saída
