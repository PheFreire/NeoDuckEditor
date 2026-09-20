**accept**

> `sys/socket.h`

O `accept` retira a próxima conexão pendente da fila de um socket em modo escuta, criando um novo socket dedicado a essa conexão específica

```c
#include <sys/socket.h>

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

- `sockfd`: o descritor do socket em modo escuta (depois de `bind` e `listen`)
- `addr`: um ponteiro para uma estrutura onde o endereço do cliente conectado será escrito; pode ser `NULL` se essa informação não for necessária
- `addrlen`: um ponteiro para o tamanho da estrutura `addr`; antes da chamada indica o tamanho disponível, depois é atualizado com o tamanho real escrito

- Retorna um novo descritor de arquivo representando a conexão com aquele cliente específico, ou `-1` em caso de erro
- Bloqueia o processo até que exista uma conexão pendente na fila, a menos que o socket tenha sido configurado como não-bloqueante
- O socket original (`sockfd`) continua em modo escuta depois do `accept`, podendo aceitar outras conexões em chamadas seguintes; toda a troca de dados com aquele cliente específico acontece pelo novo descritor retornado, não pelo original

```c
struct sockaddr_in client_address;
socklen_t client_len = sizeof(client_address);
int client_fd = accept(server_fd, (struct sockaddr *)&client_address, &client_len);
```

