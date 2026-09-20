**listen**

> `sys/socket.h`

O `listen` marca um socket como passivo, disponível para receber conexões de entrada, e define o tamanho da fila de conexões pendentes

```c
#include <sys/socket.h>

int listen(int sockfd, int backlog);
```

- `sockfd`: o descritor do socket, já associado a um endereço via `bind`
- `backlog`: o número máximo de conexões que podem ficar esperando na fila para serem aceitas via `accept`, antes de novas tentativas de conexão serem recusadas

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- Só é usado no lado servidor; depois dessa chamada, o socket não é mais usado para enviar/receber dados diretamente, apenas para aceitar novas conexões com `accept`

```c
listen(server_fd, 5);
```

