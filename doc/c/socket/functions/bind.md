**bind**

> `sys/socket.h`

O `bind` associa um socket a um endereço e porta locais, sendo o passo necessário antes de um servidor poder aceitar conexões numa porta específica

```c
#include <sys/socket.h>

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`: o descritor do socket a ser associado ao endereço
- `addr`: a estrutura de endereço (como uma `struct sockaddr_in` convertida para `struct sockaddr *`) contendo a família, a porta e o endereço IP local
- `addrlen`: o tamanho, em bytes, da estrutura apontada por `addr`

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro, por exemplo se a porta já estiver em uso por outro processo
- `INADDR_ANY` no campo `sin_addr.s_addr` faz o socket aceitar conexões chegando por qualquer interface de rede da máquina, e não apenas um IP específico
- Só faz sentido no lado que vai receber conexões (servidor); o cliente normalmente não precisa chamar `bind`, deixando o sistema escolher automaticamente uma porta local disponível ao chamar `connect`

```c
struct sockaddr_in address;
address.sin_family = AF_INET;
address.sin_addr.s_addr = INADDR_ANY;
address.sin_port = htons(8080);

bind(server_fd, (struct sockaddr *)&address, sizeof(address));
```

