**recv**

> `sys/socket.h`

O `recv` recebe dados de um socket já conectado, sendo a versão de leitura específica para sockets, com suporte a flags adicionais

```c
#include <sys/socket.h>

ssize_t recv(int sockfd, void *buf, size_t len, int flags);
```

- `sockfd`: o descritor do socket conectado de onde os dados serão lidos
- `buf`: o buffer onde os dados recebidos serão copiados
- `len`: o tamanho máximo, em bytes, que `buf` pode receber
- `flags`: opções que alteram o comportamento da chamada, por exemplo `MSG_PEEK` para ler os dados sem removê-los do buffer interno; `0` para o comportamento padrão

- Retorna quantos bytes foram de fato lidos, `0` se o outro lado fechou a conexão de forma ordenada, ou `-1` em caso de erro
- Assim como `send`, só pode ser usado em sockets já conectados; a variante `recvfrom` existe para sockets `SOCK_DGRAM`, retornando também o endereço de quem enviou os dados

```c
char buffer[1024] = {0};
recv(sock_fd, buffer, sizeof(buffer), 0);
```

