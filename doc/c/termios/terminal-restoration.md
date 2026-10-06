**Restaurando o terminal**

> como garantir que o terminal volta ao normal

A configuração `termios` pertence ao **terminal**, e não ao processo: quando o programa termina, o kernel **não** desfaz as mudanças. Se um programa em raw mode sair sem restaurar a configuração original (por um `return` esquecido, um crash ou um `Ctrl+C`), o shell continua no mesmo terminal com echo desligado, sem modo canônico e sem `\r\n`: nada aparece ao digitar, e o Enter não executa os comandos

---

**Padrão básico**

```c
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

static struct termios orig;

static void restaurar(void) {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
}

static void entrar_raw(void) {
  if (tcgetattr(STDIN_FILENO, &orig) == -1) {
    exit(1);
  }
  atexit(restaurar);          // registrado ANTES de alterar

  struct termios raw = orig;
  raw.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}
```

- `orig` é global (`static`) para que `restaurar` e os handlers de sinal tenham acesso
- `atexit(restaurar)` faz a restauração rodar em qualquer `exit()` e no `return` do `main` (ver o fim do processo em `../compilers/gcc/advanced/loader.md`)
- Registrar o `atexit` **antes** do `tcsetattr` evita uma janela em que o terminal está alterado sem nada que o restaure

---

**O que o atexit não cobre**

| Saída | `atexit` roda? | Como cobrir |
|-------|----------------|-------------|
| `return` do `main`, `exit()` | sim | — |
| `_exit()` | não | restaurar antes |
| `Ctrl+C` (`SIGINT`), `kill` (`SIGTERM`) | não | handler de sinal |
| `Ctrl+Z` (`SIGTSTP`) | — (o processo para, não termina) | restaurar no `SIGTSTP`, refazer no `SIGCONT` |
| crash (`SIGSEGV`, `SIGABRT`) | não | handler (com cuidado) |
| `kill -9` (`SIGKILL`) | não | impossível. Restaurar manualmente |

---

**Sinais**

```c
#include <signal.h>

static void ao_sinal(int sig) {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);  // async-signal-safe
  signal(sig, SIG_DFL);                        // volta a ação padrão
  raise(sig);                                  // morre do jeito normal (status de saída correto)
}

signal(SIGINT, ao_sinal);
signal(SIGTERM, ao_sinal);
signal(SIGHUP, ao_sinal);    // janela do terminal fechada
```

- Dentro de um handler, só funções **async-signal-safe** são permitidas. `tcsetattr`, `signal`, `raise` e `write` são, mas `printf`, `exit` e `malloc` não
- Com `ISIG` desligado (raw mode completo), `Ctrl+C` não gera `SIGINT`. O programa recebe o byte `3` e decide sair por conta própria, chamando `exit` normalmente
- Prefira `sigaction` a `signal` em código real. O comportamento do `signal` varia entre sistemas

---

**Suspensão com Ctrl+Z**

Ao ser suspenso, o programa devolve o terminal ao shell, que precisa da configuração normal. Ao voltar com `fg`, o programa precisa do raw mode de novo:

```c
static struct termios raw;

static void ao_suspender(int sig) {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
  signal(SIGTSTP, SIG_DFL);
  raise(SIGTSTP);                       // realmente para aqui
}

static void ao_continuar(int sig) {
  signal(SIGTSTP, ao_suspender);        // reinstala o handler
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
  // redesenhar a tela aqui, pois o shell pode ter escrito por cima
}

signal(SIGTSTP, ao_suspender);
signal(SIGCONT, ao_continuar);
```

---

**Além do termios**

Programas de tela cheia também mudam o terminal com escape sequences, e elas precisam ser desfeitas junto:

```c
static void restaurar(void) {
  write(STDOUT_FILENO, "\x1b[?25h", 6);     // mostra o cursor de volta
  write(STDOUT_FILENO, "\x1b[?1049l", 8);   // sai da tela alternativa
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
}
```

---

**Quando o terminal já quebrou**

```bash
reset        # reinicializa o terminal (termios + escape sequences)
stty sane    # restaura só o termios para valores razoáveis
```

- Como o echo pode estar desligado e o Enter pode estar enviando `\r` sem conversão, digite **sem ver** e termine com `Ctrl+J` (que envia `\n` diretamente) em vez do Enter
- `stty -g` imprime a configuração atual em uma linha. `stty "$(cat salvo)"` restaura. Útil em scripts que chamam um programa que pode quebrar o terminal

> Guarde sempre a `struct termios` **inteira** retornada pelo `tcgetattr` original e restaure exatamente ela. Reconstruir a configuração "normal" religando algumas flags (`ICANON | ECHO`) esquece as outras que o programa desligou e os valores de `c_cc`, e não respeita configurações personalizadas do usuário
