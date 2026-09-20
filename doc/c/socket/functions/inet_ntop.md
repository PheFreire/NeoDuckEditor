**inet_ntop**

> `arpa/inet.h`

O `inet_ntop` converte um endereço IP da representação binária para um texto legível, sendo o sentido contrário de `inet_pton`

```c
#include <arpa/inet.h>

const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);
```

- `af`: a família de endereços do valor binário informado, por exemplo `AF_INET` ou `AF_INET6`
- `src`: o ponteiro para o endereço em formato binário, tipicamente o campo `sin_addr` de uma `struct sockaddr_in`
- `dst`: o buffer onde o texto resultante será escrito
- `size`: o tamanho do buffer `dst`; a constante `INET_ADDRSTRLEN` já define o tamanho suficiente para um endereço IPv4

- Retorna `dst` em caso de sucesso, ou `NULL` em caso de erro, por exemplo se `dst` for pequeno demais
- Muito usado depois de um `accept`, para exibir de forma legível o endereço IP do cliente que acabou de se conectar

```c
char client_ip[INET_ADDRSTRLEN];
inet_ntop(AF_INET, &client_address.sin_addr, client_ip, sizeof(client_ip));
printf("cliente conectado: %s\n", client_ip);
```

