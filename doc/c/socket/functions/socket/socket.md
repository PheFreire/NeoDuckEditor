**socket**

> `sys/socket.h`

O `socket` cria um novo socket, retornando um descritor de arquivo usado por todas as outras funções de rede para se referir a ele

```c
#include <sys/socket.h>

int socket(int domain, int type, int protocol);
```

- `domain`: a família de endereços usada, por exemplo `AF_INET` (IPv4) ou `AF_INET6` (IPv6)
- `type`: o tipo de comunicação, por exemplo `SOCK_STREAM` (TCP, orientado a conexão) ou `SOCK_DGRAM` (UDP, sem conexão)
- `protocol`: o protocolo específico a ser usado, geralmente `0` para deixar o sistema escolher o protocolo padrão daquela combinação de `domain`/`type`

- Retorna um descritor de arquivo para o novo socket, ou `-1` em caso de erro
- O valor retornado é um `fd` como outro qualquer, podendo ser usado com `read`, `write` e `close`, além das funções específicas de rede

```c
int server_fd = socket(AF_INET, SOCK_STREAM, 0);
```

