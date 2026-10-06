**Control characters**

> array `c_cc` de `struct termios`

O `c_cc` é um array de bytes que diz à line discipline **quais caracteres têm função especial**: qual tecla gera `SIGINT`, qual apaga um caractere, qual sinaliza fim de entrada. Também guarda dois números que não são caracteres, `VMIN` e `VTIME`, usados no modo não canônico. Cada posição é acessada por uma constante de índice começando com `V`

```c
t.c_cc[VINTR]  = 3;      // Ctrl+C gera SIGINT (padrão)
t.c_cc[VEOF]   = 4;      // Ctrl+D finaliza a entrada (padrão)
t.c_cc[VMIN]   = 1;      // modo não canônico: espera 1 byte
t.c_cc[VTIME]  = 0;      // modo não canônico: sem timeout
t.c_cc[VSUSP]  = _POSIX_VDISABLE;  // desliga o Ctrl+Z
```

**Como as teclas viram bytes**

Teclas com `Ctrl` geram bytes de 0 a 31: o terminal pega a letra e zera os bits altos (`'C' & 0x1f = 3`). Por isso a notação `^C` significa "byte 3"

```text
^@ = 0   ^C = 3   ^D = 4   ^H = 8 (BS)   ^J = 10 (\n)   ^M = 13 (\r)
^Q = 17  ^S = 19  ^U = 21  ^W = 23  ^Z = 26  ^[ = 27 (ESC)  ^\ = 28  ^? = 127 (DEL)
```

- Por isso `Ctrl+M` é igual ao Enter, `Ctrl+I` é igual ao Tab e `Ctrl+[` é igual ao `Esc`: são o mesmo byte

**Índices**

| Índice | Padrão | Ativo com | Função |
|--------|--------|-----------|--------|
| `VINTR` | `^C` | `ISIG` | envia `SIGINT` |
| `VQUIT` | `^\` | `ISIG` | envia `SIGQUIT` |
| `VSUSP` | `^Z` | `ISIG` | envia `SIGTSTP` |
| `VERASE` | `^?` (127) ou `^H` | `ICANON` | apaga o último caractere |
| `VKILL` | `^U` | `ICANON` | apaga a linha inteira |
| `VEOF` | `^D` | `ICANON` | libera o buffer. Com buffer vazio, o `read()` retorna `0` |
| `VEOL` | desativado | `ICANON` | terminador de linha adicional |
| `VEOL2` | desativado | `ICANON` + `IEXTEN` | outro terminador adicional (não POSIX) |
| `VSTART` | `^Q` | `IXON`/`IXOFF` | retoma a saída |
| `VSTOP` | `^S` | `IXON`/`IXOFF` | pausa a saída |
| `VWERASE` | `^W` | `ICANON` + `IEXTEN` | apaga a última palavra (não POSIX) |
| `VREPRINT` | `^R` | `ICANON` + `IEXTEN` | reescreve a linha (não POSIX) |
| `VLNEXT` | `^V` | `IEXTEN` | insere o próximo caractere literalmente (não POSIX) |
| `VDISCARD` | `^O` | `IEXTEN` | descarta a saída (não POSIX, efetivo no macOS) |
| `VSTATUS` | `^T` | `ICANON` + `IEXTEN` | envia `SIGINFO` (só macOS/BSD) |
| `VMIN` | — | `!ICANON` | mínimo de bytes para o `read()` retornar |
| `VTIME` | — | `!ICANON` | timeout em décimos de segundo |

- `VMIN` e `VTIME` são números, não caracteres. O significado das combinações está em `raw-mode.md`
- Os índices e o tamanho do array (`NCCS`) variam entre sistemas. Sempre use os nomes

**Desativando um caractere**

```c
#include <unistd.h>   // _POSIX_VDISABLE

t.c_cc[VSUSP] = _POSIX_VDISABLE;   // Ctrl+Z deixa de suspender, mas ISIG continua ligado
```

- `_POSIX_VDISABLE` é o valor que significa "nenhum caractere": `0` (`'\0'`) no Linux, `0xff` no macOS. Use a constante, nunca o número
- Desativar um único caractere é mais preciso que desligar a flag inteira: aqui `Ctrl+C` continua gerando `SIGINT`

**Mudando uma tecla**

```c
t.c_cc[VERASE] = 8;    // Backspace passa a ser ^H em vez de ^?
t.c_cc[VINTR]  = 7;    // Ctrl+G passa a gerar SIGINT
```

- O Backspace dos terminais modernos normalmente envia `^?` (127). Alguns enviam `^H` (8). Se o `VERASE` não bater com o que o terminal envia, apertar Backspace mostra `^H` ou `^?` em vez de apagar. `stty erase ^H` corrige no shell

**Armadilhas**

- Historicamente, alguns sistemas usavam o **mesmo índice** para `VMIN` e `VEOF`, e para `VTIME` e `VEOL`, já que uns só valem em modo canônico e os outros só em modo não canônico. No Linux e no macOS os índices são diferentes, mas o código portável deve guardar a `struct` original inteira e restaurá-la, em vez de restaurar só `ICANON` e confiar nos valores de `c_cc`
- Alterar `c_cc` não tem efeito sem `tcsetattr`

> `stty -a` mostra todos os caracteres atuais (`intr = ^C; quit = ^\; erase = ^?; ...`), e `stty intr ^G` muda um deles no shell. É uma boa forma de testar uma configuração antes de escrevê-la em C
