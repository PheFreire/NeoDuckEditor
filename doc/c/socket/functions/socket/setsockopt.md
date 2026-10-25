**setsockopt**

> `sys/socket.h`

O `setsockopt` configura opções de comportamento sobre um socket já criado

```c
#include <sys/socket.h>

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
```

- `sockfd`: o descritor do socket a ser configurado
- `level`: a camada à qual a opção pertence, geralmente `SOL_SOCKET` para opções genéricas de socket
- `optname`: a opção específica a ser configurada, por exemplo `SO_REUSEADDR`
- `optval`: um ponteiro para o valor da opção
- `optlen`: o tamanho, em bytes, do valor apontado por `optval`

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- `SO_REUSEADDR` é uma das opções mais comuns ao hospedar um servidor: sem ela, tentar dar `bind` numa porta que acabou de ser usada por uma conexão anterior pode falhar por um tempo, mesmo com o processo antigo já encerrado, por causa do estado `TIME_WAIT` que o sistema mantém sobre a porta

```c
int opt = 1;
setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
```

