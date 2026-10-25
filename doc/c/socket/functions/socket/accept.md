**accept**

> `sys/socket.h`

O `accept` retira a próxima conexão pendente da fila de um socket em modo escuta, criando um novo socket dedicado a essa conexão específica

```c
#include <sys/socket.h>

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

- `sockfd`: o descritor do socket em modo escuta (depois de `bind` e `listen`)
- `addr`: um ponteiro para uma estrutura onde o endereço do cliente conectado será escrito. Pode ser `NULL` se essa informação não for necessária
- `addrlen`: um ponteiro para o tamanho da estrutura `addr`. Antes da chamada indica o tamanho disponível, depois é atualizado com o tamanho real escrito

- Retorna um novo descritor de arquivo representando a conexão com aquele cliente específico, ou `-1` em caso de erro
- Bloqueia o processo até que exista uma conexão pendente na fila, a menos que o socket tenha sido configurado como não-bloqueante
- O socket original (`sockfd`) continua em modo escuta depois do `accept`, podendo aceitar outras conexões em chamadas seguintes. Toda a troca de dados com aquele cliente específico acontece pelo novo descritor retornado, não pelo original

```c
struct sockaddr_in client_address;
socklen_t client_len = sizeof(client_address);
int client_fd = accept(server_fd, (struct sockaddr *)&client_address, &client_len);
```

> `socklen_t` é o tipo inteiro que a API de sockets usa para guardar o **tamanho em bytes de uma estrutura de endereço** (`struct sockaddr_in`, `struct sockaddr_in6` e outras). Ele vem de `sys/socket.h`, e o POSIX garante que ele é um inteiro sem sinal de pelo menos 32 bits (no Linux e no macOS é um `uint32_t`, com 4 bytes). Ele existe porque o `accept` recebe um `struct sockaddr *` genérico e não tem como saber sozinho de qual família é a estrutura que você passou, nem quanto espaço ela tem. Cada família tem um tamanho diferente (no macOS, `sockaddr_in` tem 16 bytes, `sockaddr_in6` tem 28 e `sockaddr_un` tem 106), e o `addrlen` é quem carrega essa informação. É por isso que ele é passado como ponteiro: na entrada, o `accept` lê quantos bytes pode escrever em `addr` sem passar do fim da estrutura, e na saída escreve de volta quantos bytes o endereço do cliente realmente ocupou. Por isso o `client_len` precisa ser inicializado com `sizeof(client_address)` antes de cada chamada, e precisa ser declarado como `socklen_t`, e não como `int`: passar um `int *` gera o aviso `converts between pointers to integer types with different sign` (`-Wpointer-sign`), e em plataformas onde os tamanhos diferem o `accept` escreveria no lugar errado. As outras funções que recebem ou devolvem o tamanho de um endereço usam o mesmo tipo, como `bind`, `connect`, `getsockname` e o último argumento do `setsockopt`

> Todo socket criado com `socket` já nasce **bloqueante**, então não é preciso fazer nada para ter esse comportamento. Para deixá-lo não-bloqueante, você lê as flags atuais do descritor com `int flags = fcntl(fd, F_GETFL, 0)` e grava de volta com o bit `O_NONBLOCK` ligado, usando `fcntl(fd, F_SETFL, flags | O_NONBLOCK)`. Para voltar a ser bloqueante, você grava as flags com o bit desligado, usando `fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)`. O `fcntl` e o `O_NONBLOCK` vêm de `fcntl.h` e funcionam em qualquer sistema POSIX. No Linux também dá para criar o socket já não-bloqueante passando `SOCK_STREAM | SOCK_NONBLOCK` no `type` do `socket`, mas essa flag não existe no macOS. Com o socket de escuta não-bloqueante, o `accept` não espera mais: se a fila estiver vazia ele devolve `-1` na hora, com `errno` valendo `EAGAIN` ou `EWOULDBLOCK`, e o programa tenta de novo depois, normalmente quando `poll` ou `select` avisam que existe uma conexão pronta. O socket novo devolvido pelo `accept` não herda esse modo de forma portável: no macOS ele herda o `O_NONBLOCK` do socket de escuta, enquanto no Linux ele nasce bloqueante. Por isso, se ele também precisar ser não-bloqueante, configure-o com `fcntl` depois do `accept`

