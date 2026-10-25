**ntohs**

> `arpa/inet.h`

O `ntohs` converte um valor de 16 bits da ordem de bytes de rede (network) de volta para a ordem de bytes do processador (host), sendo o sentido contrário de `htons`

```c
#include <arpa/inet.h>

uint16_t ntohs(uint16_t netshort);
```

- `netshort`: o valor de 16 bits, na ordem de bytes de rede, a ser convertido

- Retorna o mesmo valor reorganizado na ordem de bytes do host
- Usado para ler o campo `sin_port` de uma `struct sockaddr_in` recebida (por exemplo, depois de um `accept`), já que ele chega armazenado na ordem de bytes de rede

```c
printf("porta do cliente: %d\n", ntohs(client_address.sin_port));
```

