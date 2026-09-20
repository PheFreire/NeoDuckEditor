**send**

> `sys/socket.h`

O `send` envia dados por um socket já conectado, sendo a versão de escrita específica para sockets, com suporte a flags adicionais

```c
#include <sys/socket.h>

ssize_t send(int sockfd, const void *buf, size_t len, int flags);
```

- `sockfd`: o descritor do socket conectado por onde os dados serão enviados
- `buf`: o buffer contendo os dados a serem enviados
- `len`: quantos bytes de `buf` devem ser enviados
- `flags`: opções que alteram o comportamento da chamada, por exemplo `MSG_DONTWAIT` para não bloquear; `0` para o comportamento padrão

- Retorna quantos bytes foram de fato enviados, podendo ser menor que `len`, ou `-1` em caso de erro
- Só pode ser usado em sockets já conectados (via `connect`, do lado cliente, ou retornados por `accept`, do lado servidor); para sockets `SOCK_DGRAM` sem conexão, existe a variante `sendto`, que recebe o endereço de destino explicitamente

```c
char *msg = "ola servidor";
send(sock_fd, msg, strlen(msg), 0);
```

