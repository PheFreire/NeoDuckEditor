**tcgetattr e tcsetattr**

> `termios.h`

O `tcgetattr` copia a configuração atual de um terminal para uma `struct termios` do seu programa, e o `tcsetattr` aplica uma `struct termios` ao terminal. Toda alteração de `termios` segue o mesmo ciclo: ler, alterar a cópia, aplicar, e mais tarde restaurar a original

```c
int tcgetattr(int fd, struct termios *termios_p);
int tcsetattr(int fd, int optional_actions, const struct termios *termios_p);
```

- `fd`: um file descriptor aberto para o terminal, normalmente `STDIN_FILENO`
- `termios_p`: no `tcgetattr`, onde a configuração será escrita. No `tcsetattr`, a configuração a aplicar
- `optional_actions`: **quando** a nova configuração entra em vigor:
	- `TCSANOW`: imediatamente
	- `TCSADRAIN`: depois que toda a saída já escrita for transmitida
	- `TCSAFLUSH`: depois que toda a saída for transmitida, **descartando** a entrada recebida e ainda não lida

- Os dois devolvem `0` em caso de sucesso, ou `-1` em caso de erro, com o motivo em `errno`:
	- `ENOTTY`: o fd não é um terminal (arquivo, pipe, `/dev/null`)
	- `EBADF`: fd inválido
	- `EINVAL`: `optional_actions` inválido
	- `EINTR`: interrompido por um sinal (`tcsetattr`)

**O ciclo**

```c
#include <termios.h>
#include <unistd.h>
#include <stdio.h>

struct termios orig, novo;

if (tcgetattr(STDIN_FILENO, &orig) == -1) {   // 1. lê a configuração atual
  perror("tcgetattr");
  return 1;
}

novo = orig;                                   // 2. trabalha em uma cópia
novo.c_lflag &= ~ECHO;                         // 3. altera só o necessário

if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &novo) == -1) {  // 4. aplica
  perror("tcsetattr");
  return 1;
}

/* ... */

tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);     // 5. restaura a original
```

```text
 terminal (kernel)                  seu programa
┌──────────────────┐  tcgetattr   ┌──────────────┐
│ configuração     │ ───────────► │ orig         │
│ atual            │              │   │ cópia    │
│                  │  tcsetattr   │   ▼          │
│                  │ ◄─────────── │ novo (alt.)  │
└──────────────────┘              └──────────────┘
```

- `novo = orig;` copia a `struct` inteira (atribuição de struct copia todos os campos, inclusive o array `c_cc`)
- Começar de `tcgetattr` garante que os campos que você não conhece (velocidade, campos específicos do sistema) continuem válidos. Uma `struct termios` zerada com `memset` desliga inclusive `CREAD` e `CS8`

**Qual optional_actions usar**

```text
tempo ──►
saída pendente: [ "Digite a senha: " ]
entrada pendente: [ "abc" digitado antes ]

TCSANOW    aplica já; o prompt pode sair com a configuração nova
TCSADRAIN  espera o prompt sair, depois aplica; "abc" continua na fila
TCSAFLUSH  espera o prompt sair, descarta "abc", depois aplica
```

- `TCSAFLUSH` ao **entrar** em raw mode ou desligar o echo: evita que teclas digitadas antes (com outra configuração) sejam lidas depois
- `TCSADRAIN` ou `TCSAFLUSH` ao **sair**: garante que a saída escrita em raw mode seja mostrada antes de voltar ao modo normal
- `TCSANOW` em handlers de sinal e quando a velocidade de resposta importa mais que a fila

**Armadilhas**

- `tcsetattr` devolve **sucesso se pelo menos uma** das mudanças foi aplicada, e não todas (regra do POSIX). Para configurações críticas (portas seriais), leia de volta e compare:

```c
struct termios conferida;
tcsetattr(fd, TCSANOW, &novo);
tcgetattr(fd, &conferida);
if ((conferida.c_cflag & CSIZE) != CS8) {
  // o dispositivo não aceitou 8 bits
}
```

- Comparar a `struct` inteira com `memcmp` pode dar diferença falsa, por causa de campos internos e bytes de padding
- Um processo em **background** que chama `tcsetattr` recebe `SIGTTOU` e é suspenso (a não ser que ignore ou bloqueie esse sinal)
- A configuração é do **terminal**, e não do processo: vale para o shell e para qualquer outro programa que use o mesmo terminal, até alguém restaurá-la (ver `terminal-restoration.md`)
- `tcsetattr` é **async-signal-safe**, então pode ser chamado dentro de um handler de sinal para restaurar o terminal

> Antes de chamar `tcgetattr`, verifique com `isatty(STDIN_FILENO)` se há um terminal. Se o programa for usado em scripts (`./app < entrada.txt`), ele deve funcionar sem alterar nada, em vez de falhar com `ENOTTY`
