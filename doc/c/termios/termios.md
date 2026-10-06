**termios**

> `termios.h` (POSIX)

O `termios` é a interface POSIX para ler e alterar a configuração de um **terminal**: se a entrada é entregue linha por linha ou tecla por tecla, se o que é digitado aparece na tela, se `Ctrl+C` gera um sinal, se o `Enter` vira `\n`, e, em portas seriais, a velocidade, os bits por caractere e a paridade. Ele não lê nem escreve dados: só configura **como** o kernel trata os dados que passam pelo terminal antes de chegarem ao seu `read()` e depois de saírem do seu `write()`

> O `termios` **não** é uma biblioteca para desenhar interfaces no terminal. Cores, mover o cursor, limpar a tela e tamanho da janela são feitos com escape sequences (`\x1b[2J`, `\x1b[31m`...) escritas com `write()`, e com `ioctl(TIOCGWINSZ)`. Bibliotecas como `ncurses` usam o `termios` por baixo para colocar o terminal em raw mode, mas desenham com escape sequences

```c
#include <termios.h>
#include <unistd.h>

struct termios {
  tcflag_t c_iflag;   // input modes:   como os bytes de entrada são transformados
  tcflag_t c_oflag;   // output modes:  como os bytes de saída são transformados
  tcflag_t c_cflag;   // control modes: parâmetros de hardware (bits, paridade, velocidade)
  tcflag_t c_lflag;   // local modes:   echo, modo canônico, sinais
  cc_t     c_cc[NCCS];// control chars: quais teclas fazem o quê (Ctrl+C, Backspace, EOF...)
};
```

- Esses são os campos garantidos pelo POSIX. Cada sistema pode ter campos extras (`c_line`, `c_ispeed` e `c_ospeed` no Linux, `c_ispeed` e `c_ospeed` no macOS). Por isso nunca monte uma `struct termios` do zero: sempre leia a atual com `tcgetattr` e altere só o que precisa
- `tcflag_t` é um inteiro sem sinal usado como conjunto de bits (`unsigned int` no Linux, `unsigned long` no macOS). `cc_t` é um `unsigned char`. Ver `terminal-attributes.md`

**Funções principais**

| Função | O que faz | Ver |
|--------|-----------|-----|
| `tcgetattr(fd, &t)` | lê a configuração atual do terminal para `t` | `tcgetattr-tcsetattr.md` |
| `tcsetattr(fd, quando, &t)` | aplica a configuração de `t` | `tcgetattr-tcsetattr.md` |
| `cfmakeraw(&t)` | altera `t` para raw mode (não POSIX) | `raw-mode.md` |
| `tcflush(fd, fila)` | descarta dados pendentes de entrada e/ou saída | `tcflush-tcdrain.md` |
| `tcdrain(fd)` | espera toda a saída pendente ser transmitida | `tcflush-tcdrain.md` |
| `cfsetispeed` / `cfsetospeed` | define a velocidade (baud rate) | `baud-rate.md` |
| `isatty(fd)` (`unistd.h`) | diz se `fd` é um terminal | `terminal-and-tty.md` |

**File descriptors**

Toda função do `termios` recebe um **file descriptor**, e não um `FILE *`. A configuração pertence ao **dispositivo de terminal** aberto por aquele fd, e não ao fd em si nem ao processo:

```c
struct termios t;
if (tcgetattr(STDIN_FILENO, &t) == -1) {
  perror("tcgetattr"); // ENOTTY: stdin não é um terminal (ex: ./app < arquivo.txt)
  return 1;
}
```

- `STDIN_FILENO` (`0`), `STDOUT_FILENO` (`1`) e `STDERR_FILENO` (`2`), de `unistd.h`, normalmente apontam todos para o **mesmo** terminal. Alterar a configuração por qualquer um deles afeta os três
- Como a configuração fica no terminal, ela **sobrevive ao fim do seu processo**: se o programa sair sem restaurar, o shell continua usando o terminal alterado. Ver `terminal-restoration.md`
- Se a entrada vier de um arquivo ou de um pipe, não há terminal: as funções falham com `ENOTTY`, e o `read()` simplesmente lê os bytes do arquivo, sem nenhum processamento

**Categorias de flags**

Entrada (o que você digita):

```text
teclado
  │  c_iflag   converte o Enter (\r) em \n
  ▼
  │  c_lflag   junta a linha, mostra na tela, Ctrl+C vira sinal
  ▼
read()
```

Saída (o que o programa escreve):

```text
write()
  │  c_oflag   converte \n em \r\n
  ▼
tela
```

O `c_cflag` fica fora desses caminhos: ele define o formato dos bytes no hardware (velocidade, bits, paridade) e só importa em portas seriais

- `c_iflag` (ver `input-flags.md`): transformações nos bytes que chegam, como converter o `\r` do Enter em `\n` (`ICRNL`) e o controle de fluxo com `Ctrl+S`/`Ctrl+Q` (`IXON`)
- `c_oflag` (ver `output-flags.md`): transformações nos bytes enviados, principalmente `\n` → `\r\n` (`OPOST` + `ONLCR`)
- `c_cflag` (ver `control-flags.md`): formato dos caracteres na linha física. Importante em portas seriais, quase irrelevante em terminais virtuais
- `c_lflag` (ver `local-flags.md`): o comportamento "visível": modo canônico (`ICANON`), echo (`ECHO`) e sinais de teclado (`ISIG`)
- `c_cc` (ver `control-characters.md`): quais caracteres têm função especial (`VINTR` = `Ctrl+C`, `VERASE` = Backspace, `VEOF` = `Ctrl+D`) e os parâmetros `VMIN`/`VTIME` do modo não canônico

> No terminal, o comando `stty -a` mostra a configuração atual com os mesmos nomes de flags (`-icanon` = desligada, `icanon` = ligada). É a forma mais rápida de ver o efeito de uma mudança: rode o seu programa em um terminal e `stty -a < /dev/pts/N` (Linux) ou `stty -a -f /dev/ttysNNN` (macOS) em outro
