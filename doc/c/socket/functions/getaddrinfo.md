**getaddrinfo**

> `netdb.h`

O `getaddrinfo` resolve um host (endereço IP ou nome, como `"exemplo.com"`) e um serviço (porta numérica ou nome, como `"80"` ou `"http"`) para uma ou mais estruturas de endereço já prontas para uso em `bind` ou `connect`, sem o código precisar saber de antemão se o resultado será IPv4 ou IPv6

```c
#include <netdb.h>

int getaddrinfo(const char *node, const char *service,
                 const struct addrinfo *hints,
                 struct addrinfo **res);
```

- `node`: o host a resolver, podendo ser um endereço IP (`"127.0.0.1"`) ou um nome (`"exemplo.com"`); pode ser `NULL` quando `hints.ai_flags` incluir `AI_PASSIVE`, indicando que o endereço será usado para escutar conexões (lado servidor), e não para se conectar a alguém
- `service`: a porta a resolver, como texto, podendo ser um número (`"8080"`) ou um nome de serviço conhecido (`"http"`)
- `hints`: um ponteiro para uma `struct addrinfo` preenchida parcialmente, usada para filtrar os resultados; por exemplo, `hints.ai_family = AF_UNSPEC` aceita tanto IPv4 quanto IPv6, e `hints.ai_socktype = SOCK_STREAM` filtra apenas endereços compatíveis com TCP. Pode ser `NULL` para aceitar qualquer resultado
- `res`: o endereço de um ponteiro que vai receber, na saída, o início de uma lista encadeada de resultados

- Retorna `0` em caso de sucesso, ou um código de erro diferente de zero em caso de falha; esse código não é compatível com `errno`, sendo necessário usar `gai_strerror` para obter uma mensagem legível a partir dele
- Como um mesmo host pode ter mais de um endereço associado (por exemplo, um IPv4 e um IPv6), o resultado em `res` é uma lista encadeada através do campo `ai_next` de cada `struct addrinfo`; o padrão é percorrer essa lista tentando `socket`/`bind` (servidor) ou `socket`/`connect` (cliente) em cada endereço até um deles funcionar
- Cada nó da lista já contém uma `struct sockaddr` pronta (`ai_addr`) e seu tamanho (`ai_addrlen`), dispensando montar `sin_family`/`sin_port`/`sin_addr` manualmente
- Ao usar `AI_PASSIVE` com `node = NULL`, o endereço retornado equivale a usar `INADDR_ANY` manualmente, servindo para um servidor aceitar conexões em qualquer interface local

```c
struct addrinfo hints, *res;
memset(&hints, 0, sizeof(hints));
hints.ai_family = AF_UNSPEC;
hints.ai_socktype = SOCK_STREAM;
hints.ai_flags = AI_PASSIVE;

getaddrinfo(NULL, "8080", &hints, &res);

int server_fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
bind(server_fd, res->ai_addr, res->ai_addrlen);
```

