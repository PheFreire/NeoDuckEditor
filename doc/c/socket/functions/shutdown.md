**shutdown**

> `sys/socket.h`

O `shutdown` encerra parte ou toda a comunicação de um socket conectado, sem necessariamente liberar o descritor de arquivo em si

```c
#include <sys/socket.h>

int shutdown(int sockfd, int how);
```

- `sockfd`: o descritor do socket cuja comunicação será encerrada
- `how`: qual direção da comunicação encerrar; `SHUT_RD` para leitura, `SHUT_WR` para escrita, ou `SHUT_RDWR` para ambas

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- Diferente de `close`, o `shutdown` não libera o `fd`: ele apenas avisa o outro lado da conexão (via TCP) que não virão mais dados naquela direção, permitindo, por exemplo, terminar de enviar dados enquanto ainda espera uma resposta
- Se o socket tiver sido duplicado (`dup`) e compartilhado por mais de um processo, `shutdown` afeta a conexão para todos eles de uma vez, diferente de `close`, que só remove a referência local

```c
shutdown(client_fd, SHUT_RDWR);
```

