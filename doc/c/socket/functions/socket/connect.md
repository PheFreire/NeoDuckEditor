**connect**

> `sys/socket.h`

O `connect` inicia uma conexão de um socket para um endereço remoto, sendo a chamada usada pelo lado cliente para se conectar a um servidor

```c
#include <sys/socket.h>

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

- `sockfd`: o descritor do socket que vai iniciar a conexão
- `addr`: a estrutura de endereço do servidor remoto (família, porta e IP de destino)
- `addrlen`: o tamanho, em bytes, da estrutura apontada por `addr`

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro, por exemplo se não houver nada escutando naquele endereço/porta
- Bloqueia o processo até a conexão ser estabelecida ou falhar, a menos que o socket tenha sido configurado como não-bloqueante
- Diferente do servidor, o cliente normalmente não precisa de `bind` antes: o sistema escolhe automaticamente uma porta local livre para a conexão

```c
struct sockaddr_in server_address;
server_address.sin_family = AF_INET;
server_address.sin_port = htons(8080);
inet_pton(AF_INET, "127.0.0.1", &server_address.sin_addr);

connect(sock_fd, (struct sockaddr *)&server_address, sizeof(server_address));
```

> Se o socket estiver em modo não-bloqueante (ver `functions/socket/accept.md`), o `connect` não espera o handshake terminar: ele devolve `-1` na hora com `errno` valendo `EINPROGRESS`, e o kernel continua fazendo a conexão em segundo plano. Para saber quando ela terminou, você espera o socket ficar pronto para escrita com `poll` ou `select` e depois lê o resultado com `getsockopt(fd, SOL_SOCKET, SO_ERROR, &erro, &len)`. Se `erro` valer `0` a conexão foi estabelecida, senão ele guarda o código do erro, como `ECONNREFUSED`

