**htons**

> `arpa/inet.h`

O `htons` converte um valor de 16 bits da ordem de bytes do processador (host) para a ordem de bytes de rede (network), usada para transmitir dados entre máquinas diferentes

```c
#include <arpa/inet.h>

uint16_t htons(uint16_t hostshort);
```

- `hostshort`: o valor de 16 bits, na ordem de bytes do host, a ser convertido

- Retorna o mesmo valor reorganizado na ordem de bytes de rede (big-endian)
- Usado para preencher o campo `sin_port` de uma `struct sockaddr_in`, já que portas são armazenadas em rede na ordem de bytes de rede, independente da arquitetura da máquina local
- Em máquinas cuja arquitetura já é big-endian, a função não altera os bytes, apenas retorna o mesmo valor

```c
address.sin_port = htons(8080);
```

