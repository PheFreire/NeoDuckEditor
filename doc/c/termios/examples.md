**Exemplos**

> programas completos e pequenos usando `termios`

Exemplos prontos para compilar, cada um mostrando um uso real. Todos guardam a configuração original e a restauram antes de sair (ver `terminal-restoration.md`)

```bash
gcc -Wall -Wextra exemplo.c -o exemplo
```

---

**1. Ler uma senha sem mostrar na tela**

Desliga só o `ECHO`: a linha continua editável com Backspace, o Enter confirma e o `Ctrl+C` continua funcionando

```c
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

int ler_senha(char *buf, int tam) {
  struct termios orig, t;
  if (tcgetattr(STDIN_FILENO, &orig) == -1) {
    return -1;
  }

  t = orig;
  t.c_lflag &= ~ECHO;     // não mostra o que é digitado
  t.c_lflag |= ECHONL;    // mas mostra o Enter, para o cursor descer
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &t);

  char *ok = fgets(buf, tam, stdin);   // modo canônico: espera o Enter

  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
  if (ok == NULL) {
    return -1;
  }
  buf[strcspn(buf, "\n")] = '\0';
  return 0;
}

int main(void) {
  char senha[64];
  printf("Senha: ");
  fflush(stdout);                      // o prompt não tem \n
  if (ler_senha(senha, sizeof(senha)) == 0) {
    printf("recebi %zu caracteres\n", strlen(senha));
  }
  return 0;
}
```

- O `getpass()` faz isso, mas é obsoleto e removido do POSIX. O código acima é o equivalente explícito

---

**2. "Pressione qualquer tecla"**

Modo não canônico só pelo tempo de uma leitura

```c
#include <stdio.h>
#include <termios.h>
#include <unistd.h>

int ler_tecla(void) {
  struct termios orig, t;
  tcgetattr(STDIN_FILENO, &orig);
  t = orig;
  t.c_lflag &= ~(ICANON | ECHO);   // não espera o Enter, não mostra
  t.c_cc[VMIN]  = 1;
  t.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &t);

  unsigned char c = 0;
  ssize_t n = read(STDIN_FILENO, &c, 1);

  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
  return n == 1 ? c : -1;
}

int main(void) {
  printf("Pressione qualquer tecla...\n");
  int c = ler_tecla();
  printf("tecla: %d\n", c);
  return 0;
}
```

- Usa `read()` em vez de `getchar()`: o `getchar` lê através do buffer do `stdio`, que pode guardar bytes além do primeiro e confundir leituras futuras

---

**3. Mostrar o byte de cada tecla (raw mode)**

Ótimo para entender o que cada tecla realmente envia: `Ctrl+C` = 3, Enter = 13, seta para cima = `27 91 65`

```c
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

static struct termios orig;

static void restaurar(void) {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
}

int main(void) {
  if (!isatty(STDIN_FILENO)) {
    fprintf(stderr, "stdin não é um terminal\n");
    return 1;
  }
  tcgetattr(STDIN_FILENO, &orig);
  atexit(restaurar);

  struct termios raw = orig;
  cfmakeraw(&raw);               // extensão BSD/glibc, ver raw-mode.md
  raw.c_cc[VMIN]  = 1;
  raw.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);

  printf("aperte teclas, 'q' para sair\r\n");   // sem OPOST: \r\n
  unsigned char c;
  while (read(STDIN_FILENO, &c, 1) == 1 && c != 'q') {
    if (iscntrl(c)) {
      printf("%d\r\n", c);
    } else {
      printf("%d ('%c')\r\n", c, c);
    }
    fflush(stdout);
  }
  return 0;                      // atexit restaura
}
```

- Sem `ISIG`, o `Ctrl+C` aparece como `3` e não encerra: a única saída é o `q`

---

**4. Teclas de seta**

Setas enviam uma sequência começando com `ESC` (27). Com `VMIN=0` e `VTIME=1`, o `read()` espera no máximo 0,1 s por cada byte, o que permite diferenciar um `Esc` sozinho do início de uma sequência

```c
enum { TECLA_CIMA = 1000, TECLA_BAIXO, TECLA_DIREITA, TECLA_ESQUERDA };

int ler_tecla_raw(void) {
  unsigned char c;
  while (read(STDIN_FILENO, &c, 1) != 1) {
    // VTIME expirou sem tecla: volta a esperar
  }
  if (c != 27) {
    return c;
  }

  unsigned char seq[2];
  if (read(STDIN_FILENO, &seq[0], 1) != 1) return 27;   // ESC sozinho
  if (read(STDIN_FILENO, &seq[1], 1) != 1) return 27;

  if (seq[0] == '[') {
    switch (seq[1]) {
      case 'A': return TECLA_CIMA;
      case 'B': return TECLA_BAIXO;
      case 'C': return TECLA_DIREITA;
      case 'D': return TECLA_ESQUERDA;
    }
  }
  return 27;
}
```

- Configure o terminal como no exemplo 3, trocando para `raw.c_cc[VMIN] = 0; raw.c_cc[VTIME] = 1;`
- As sequências vêm do terminal emulator, e não do `termios`. Alguns emulators enviam `ESC O A` em vez de `ESC [ A` (modo "application cursor keys")

---

**5. Verificar tecla sem bloquear**

Para laços de jogo ou animação, que precisam continuar rodando mesmo sem tecla:

```c
// com o terminal em raw mode e VMIN = 0, VTIME = 0
unsigned char c;
ssize_t n = read(STDIN_FILENO, &c, 1);
if (n == 1) {
  // tecla disponível
} else {
  // nenhuma tecla: read() retornou 0 imediatamente
}
```

- Alternativa: manter `VMIN=1` e usar `poll()`/`select()` com timeout no `STDIN_FILENO`, o que permite esperar teclado e outros fds (sockets, timers) ao mesmo tempo

---

**6. Configurar uma porta serial (8N1, 115200)**

```c
#include <fcntl.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>

int abrir_serial(const char *caminho) {
  int fd = open(caminho, O_RDWR | O_NOCTTY);
  if (fd == -1) {
    perror("open");
    return -1;
  }

  struct termios t;
  if (tcgetattr(fd, &t) == -1) {
    perror("tcgetattr");
    close(fd);
    return -1;
  }

  cfmakeraw(&t);                               // bytes crus, sem echo nem conversões
  t.c_cflag &= ~(CSTOPB | CRTSCTS);            // 1 stop bit, sem controle de fluxo por hardware
  t.c_cflag |= CREAD | CLOCAL;                 // receptor ligado, ignora linhas de modem
  t.c_cc[VMIN]  = 0;
  t.c_cc[VTIME] = 10;                          // read() espera até 1 s
  cfsetispeed(&t, B115200);
  cfsetospeed(&t, B115200);

  if (tcsetattr(fd, TCSANOW, &t) == -1) {
    perror("tcsetattr");
    close(fd);
    return -1;
  }
  tcflush(fd, TCIOFLUSH);                      // descarta lixo antigo
  return fd;
}

int main(void) {
  int fd = abrir_serial("/dev/ttyUSB0");       // macOS: /dev/cu.usbserial-XXXX
  if (fd == -1) {
    return 1;
  }
  write(fd, "PING\r\n", 6);
  tcdrain(fd);                                 // espera sair pela porta

  char buf[128];
  ssize_t n = read(fd, buf, sizeof(buf) - 1);  // retorna 0 se nada chegar em 1 s
  if (n > 0) {
    buf[n] = '\0';
    printf("resposta: %s\n", buf);
  }
  close(fd);
  return 0;
}
```

- `cfmakeraw` já define `CS8` e desliga `PARENB`, completando o 8N1 (ver `control-flags.md`)
- Uma porta serial não é o terminal do usuário, então aqui não é preciso restaurar a configuração ao sair

> Para experimentar sem hardware, o `socat -d -d pty,raw,echo=0 pty,raw,echo=0` cria dois PTYs conectados entre si. Um programa abre um, e você usa o outro com `screen /dev/pts/N` ou outro programa como se fosse o dispositivo
