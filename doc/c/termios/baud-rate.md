**Baud rate**

> velocidade de transmissão de um terminal

O baud rate é a velocidade com que os bits são transmitidos em uma linha serial, em símbolos por segundo (em serial comum, bits por segundo). Os dois lados da comunicação precisam usar **a mesma** velocidade: se o programa lê a 9600 e o dispositivo envia a 115200, os bits são interpretados nos instantes errados e chegam como lixo. Em um PTY (terminal emulator, `ssh`), a velocidade é só um número guardado, sem efeito real na transmissão

```c
speed_t cfgetispeed(const struct termios *t);
speed_t cfgetospeed(const struct termios *t);
int cfsetispeed(struct termios *t, speed_t speed);
int cfsetospeed(struct termios *t, speed_t speed);
int cfsetspeed(struct termios *t, speed_t speed);   // não POSIX: entrada e saída juntas
```

- `t`: a `struct termios` a ler ou alterar. As funções **não** falam com o terminal, só mexem na cópia. A mudança só vale depois do `tcsetattr`
- `speed`: uma constante `B<velocidade>`: `B0`, `B1200`, `B9600`, `B19200`, `B38400`, `B57600`, `B115200`, `B230400`...
- `cfset*` devolve `0` em sucesso, ou `-1` com `EINVAL` se a velocidade não for suportada

```c
struct termios t;
tcgetattr(fd, &t);
cfsetispeed(&t, B115200);   // velocidade de recepção
cfsetospeed(&t, B115200);   // velocidade de transmissão
tcsetattr(fd, TCSANOW, &t);
```

- Quase todos os dispositivos usam a mesma velocidade nos dois sentidos. Chamar os dois `cfset*` (ou o `cfsetspeed`) é o padrão
- `B0` tem um significado especial na saída: "desligar a linha" (baixa o `DTR`, o que equivale a desligar um modem)

**As constantes não são números**

```c
// Linux: B9600 == 0000015 (código octal), B115200 == 0010002
// macOS: B9600 == 9600, B115200 == 115200
cfsetospeed(&t, 9600);   // ERRADO no Linux: 9600 não é um código válido
```

- No Linux, os `B*` são códigos guardados em bits do `c_cflag` (`CBAUD`). No macOS, são o próprio valor numérico, guardado em `c_ispeed`/`c_ospeed`
- Por isso, use sempre as constantes. Para converter um número informado pelo usuário, faça um `switch`:

```c
speed_t para_speed(int baud) {
  switch (baud) {
    case 9600:   return B9600;
    case 19200:  return B19200;
    case 57600:  return B57600;
    case 115200: return B115200;
    default:     return (speed_t)-1;   // não suportada
  }
}
```

**Velocidades não padronizadas**

- O POSIX só garante as velocidades até `B38400`. `B57600` e acima são extensões, presentes no Linux e no macOS
- Velocidades fora da lista (como 250000, usada em algumas impressoras 3D) exigem interfaces específicas: no Linux, `ioctl` com `struct termios2` e a flag `BOTHER`. No macOS, `ioctl(fd, IOSSIOSPEED, &speed)`
- O adaptador USB-serial também precisa suportar a velocidade. O `tcsetattr` pode retornar sucesso e o hardware usar outra (leia de volta para conferir, ver `tcgetattr-tcsetattr.md`)

**Velocidade e tempo de transmissão**

Em 8N1, cada byte usa 10 bits na linha (1 start + 8 dados + 1 stop):

```text
9600 baud   → ~960 bytes/s   → 1 KB em ~1 s
115200 baud → ~11520 bytes/s → 1 KB em ~0,09 s
```

- `write()` retorna antes da transmissão terminar. Use `tcdrain` para esperar (ver `tcflush-tcdrain.md`)

**Abrindo uma porta serial**

```c
#include <fcntl.h>

int fd = open("/dev/ttyUSB0", O_RDWR | O_NOCTTY);   // Linux
// macOS: "/dev/cu.usbserial-XXXX"
```

- `O_NOCTTY`: impede que a porta vire o terminal de controle do processo (senão, sinais da porta poderiam afetar o programa)
- Linux: `/dev/ttyUSB*` (adaptadores USB-serial), `/dev/ttyACM*` (Arduino e dispositivos CDC), `/dev/ttyS*` (portas da placa-mãe). O usuário normalmente precisa estar no grupo `dialout` (ou `uucp`)
- macOS: cada porta aparece duas vezes. `/dev/tty.*` espera o sinal de carrier (`DCD`) no `open()` e pode bloquear. `/dev/cu.*` ("call-up") não espera. Para programas que iniciam a comunicação, use `cu.*`

> Em PTYs, `cfgetospeed` costuma devolver `B38400` ou `B9600` por padrão, um valor sem significado. Alguns programas antigos usam a velocidade para decidir quanto redesenhar a tela. Em código novo, ignore a velocidade fora de portas seriais
