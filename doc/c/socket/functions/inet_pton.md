**inet_pton**

> `arpa/inet.h`

O `inet_pton` converte um endereço IP em formato textual (como `"127.0.0.1"`) para sua representação binária, usada internamente pelas structs de endereço

```c
#include <arpa/inet.h>

int inet_pton(int af, const char *src, void *dst);
```

- `af`: a família de endereços do texto informado, por exemplo `AF_INET` ou `AF_INET6`
- `src`: a string com o endereço em formato legível
- `dst`: o ponteiro para onde o endereço convertido em binário será escrito, tipicamente o campo `sin_addr` de uma `struct sockaddr_in`

- Retorna `1` em caso de sucesso, `0` se `src` não for um endereço válido para a família informada, ou `-1` em caso de erro na própria chamada (por exemplo `af` inválido)
- O nome vem de "presentation to network", o sentido contrário de `inet_ntop`, que converte de binário para texto

```c
inet_pton(AF_INET, "127.0.0.1", &server_address.sin_addr);
```

