**Tutorial Prático: Servidor e Cliente TCP**

A baixo temos um exemplo minimo de um servidor e um cliente TCP conversando entre si, cobrindo o fluxo típico do início ao fim

Servidor: cria o socket, associa a uma porta, começa a escutar, aceita uma conexão, lê uma mensagem e responde

```c
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

int main() {
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);

    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(8080);

    bind(server_fd, (struct sockaddr *)&address, sizeof(address));
    listen(server_fd, 5);

    struct sockaddr_in client_address;
    socklen_t client_len = sizeof(client_address);
    int client_fd = accept(server_fd, (struct sockaddr *)&client_address, &client_len);

    char client_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &client_address.sin_addr, client_ip, sizeof(client_ip));
    printf("cliente conectado: %s:%d\n", client_ip, ntohs(client_address.sin_port));

    char buffer[1024] = {0};
    read(client_fd, buffer, sizeof(buffer));
    printf("cliente enviou: %s\n", buffer);

    char *resposta = "mensagem recebida";
    write(client_fd, resposta, strlen(resposta));

    shutdown(client_fd, SHUT_RDWR);
    close(client_fd);
    close(server_fd);
    return 0;
}
```

Cliente: cria o socket, conecta ao endereço do servidor, envia uma mensagem e lê a resposta

```c
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

int main() {
    int sock_fd = socket(AF_INET, SOCK_STREAM, 0);

    struct sockaddr_in server_address;
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(8080);
    inet_pton(AF_INET, "127.0.0.1", &server_address.sin_addr);

    connect(sock_fd, (struct sockaddr *)&server_address, sizeof(server_address));

    char *msg = "ola servidor";
    send(sock_fd, msg, strlen(msg), 0);

    char buffer[1024] = {0};
    recv(sock_fd, buffer, sizeof(buffer), 0);
    printf("servidor respondeu: %s\n", buffer);

    close(sock_fd);
    return 0;
}
```

O fluxo do lado do servidor é sempre `socket` → `bind` → `listen` → `accept`, e a partir daí o `client_fd` retornado por `accept` funciona como qualquer outro socket conectado, podendo trocar dados com `send`/`recv` ou `write`/`read`. Já o cliente não precisa de `bind` nem `listen`: ele só cria o socket e usa `connect` diretamente para iniciar a conexão com o servidor.
