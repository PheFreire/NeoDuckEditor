**arpa/inet.h**

> `arpa/inet.h`

A `arpa/inet.h` é o header de conversões da API de sockets: traduz endereços IP entre texto (`"127.0.0.1"`) e o formato binário guardado nas structs de endereço, e converte números entre a ordem de bytes do processador e a ordem de bytes da rede. Ela não cria, não conecta e não envia nada, só prepara os valores que as funções de `sys/socket.h` vão usar

> O nome vem da época da ARPANET, a rede que deu origem à internet: os headers dos protocolos de rede do Unix ficavam no diretório `arpa/`, e o `inet` é de internet. Hoje é só o lugar onde ficaram as funções de conversão de endereços IPv4 e IPv6

```c
#include <arpa/inet.h>
```

- `htons` e `ntohs`: convertem um valor de 16 bits (porta) entre a ordem do host e a ordem da rede
- `htonl` e `ntohl`: o mesmo para valores de 32 bits (endereço IPv4 guardado como número)
- `inet_pton`: converte um IP em texto para binário, tanto IPv4 quanto IPv6
- `inet_ntop`: converte um IP em binário para texto, o caminho inverso do `inet_pton`
- `inet_addr` e `inet_ntoa`: as versões antigas, só para IPv4, que não devem ser usadas em código novo (ver abaixo)
- Também define os tipos `in_addr_t`, `in_port_t` e `struct in_addr`, e as constantes `INET_ADDRSTRLEN` e `INET6_ADDRSTRLEN`, que dão o tamanho do buffer para um IP em texto

---

**Onde cada header entra**

A API de sockets do C não está em um header só. Cada parte fica em um lugar diferente, e a `arpa/inet.h` é uma das partes opcionais:

| header | o que fornece | obrigatório para um servidor |
|---|---|---|
| `sys/socket.h` | `socket`, `bind`, `listen`, `accept`, `connect`, `send`, `recv`, `sendto`, `recvfrom`, `struct sockaddr`, `AF_INET`, `SOCK_STREAM`, `SOCK_DGRAM` | sim |
| `netinet/in.h` | `struct sockaddr_in`, `struct sockaddr_in6`, `INADDR_ANY`, `IPPROTO_TCP`, `htons`, `htonl` | sim, para montar o endereço IPv4 ou IPv6 |
| `unistd.h` | `close`, `read`, `write` | sim, para fechar o socket |
| `arpa/inet.h` | `inet_pton`, `inet_ntop`, `htons`, `ntohs` | não, só para IP em texto |
| `netdb.h` | `getaddrinfo`, `freeaddrinfo`, `getnameinfo` | não, é a alternativa que monta o endereço sozinha |

- O `sys/socket.h` é genérico: só conhece a `struct sockaddr`, que serve para qualquer família de endereços. A versão específica de IPv4 (`struct sockaddr_in`) e de IPv6 (`struct sockaddr_in6`) vem do `netinet/in.h`
- As funções `htons`, `htonl`, `ntohs` e `ntohl` são declaradas tanto no `netinet/in.h` quanto no `arpa/inet.h`, o POSIX garante as duas

---

**É obrigatória para hospedar um servidor?**

Não. Um servidor TCP ou UDP só precisa de `sys/socket.h`, `netinet/in.h` e `unistd.h`. Quando o servidor escuta em todas as interfaces (`INADDR_ANY`), nenhum IP em texto precisa ser convertido, e a porta é convertida com o `htons` do `netinet/in.h`:

```c
#include <stdio.h>
#include <sys/socket.h>   // socket, bind, listen, accept
#include <netinet/in.h>   // struct sockaddr_in, INADDR_ANY, htons, htonl
#include <unistd.h>       // read, write, close

int main(void) {
  int server_fd = socket(AF_INET, SOCK_STREAM, 0);

  struct sockaddr_in address = {0};
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = htonl(INADDR_ANY);  // qualquer interface
  address.sin_port = htons(8080);

  bind(server_fd, (struct sockaddr *)&address, sizeof(address));
  listen(server_fd, 5);

  int client_fd = accept(server_fd, NULL, NULL);  // NULL: não quer saber quem é o cliente

  char buffer[64] = {0};
  read(client_fd, buffer, sizeof(buffer) - 1);
  printf("recebido: %s\n", buffer);

  close(client_fd);
  close(server_fd);
  return 0;
}
```

- Para UDP o caminho é o mesmo, trocando `SOCK_STREAM` por `SOCK_DGRAM` e `listen`/`accept`/`read` por `recvfrom`, que também está em `sys/socket.h`
- A `arpa/inet.h` só passa a ser necessária quando o IP aparece como texto: escutar só em `"127.0.0.1"` (`inet_pton`) ou mostrar o IP do cliente que conectou (`inet_ntop`)

---

**Por que quase todo exemplo inclui ela**

No Linux e no macOS, a `arpa/inet.h` inclui o `netinet/in.h`, que por sua vez inclui o `sys/socket.h`. Por isso um único `#include <arpa/inet.h>` já dá acesso a toda a API, como no exemplo de `socket_summary.md`, e muita gente acha que ela é a biblioteca principal dos sockets

```c
#include <arpa/inet.h>   // compila no Linux e no macOS: socket, sockaddr_in e htons vieram junto

#include <sys/socket.h>  // sozinho não basta:
struct sockaddr_in a;    // erro: variable has incomplete type 'struct sockaddr_in'
```

- O POSIX diz apenas que a `arpa/inet.h` **pode** tornar visíveis os nomes do `netinet/in.h`, então um código que depende disso pode não compilar em outro sistema
- O correto é incluir cada header pelo que se usa dele: `sys/socket.h` para as funções de socket, `netinet/in.h` para a `struct sockaddr_in` e `arpa/inet.h` só se chamar `inet_pton` ou `inet_ntop`

---

**IP em texto: inet_pton e inet_ntop**

```c
#include <arpa/inet.h>

struct sockaddr_in address = {0};
address.sin_family = AF_INET;
address.sin_port = htons(8080);
inet_pton(AF_INET, "127.0.0.1", &address.sin_addr);  // texto para binário, já na ordem da rede

char ip[INET_ADDRSTRLEN];
inet_ntop(AF_INET, &address.sin_addr, ip, sizeof(ip));  // binário para texto
printf("%s:%d\n", ip, ntohs(address.sin_port));        // 127.0.0.1:8080
```

- O `inet_pton` já escreve o endereço na ordem de bytes da rede, então não se usa `htonl` depois dele. Só a porta precisa do `htons`
- O `p` é de presentation (texto legível) e o `n` é de network (binário na ordem da rede): `pton` é texto para rede e `ntop` é rede para texto
- Os dois aceitam `AF_INET` e `AF_INET6`. Para IPv6, o destino é o campo `sin6_addr` de uma `struct sockaddr_in6` e o buffer de texto usa `INET6_ADDRSTRLEN`

---

**As funções antigas: inet_addr e inet_ntoa**

```c
address.sin_addr.s_addr = inet_addr("127.0.0.1");   // antigo, só IPv4
printf("%s\n", inet_ntoa(address.sin_addr));        // antigo, buffer estático
```

- Só funcionam com IPv4
- O `inet_addr` devolve `INADDR_NONE` em caso de erro, que é o mesmo valor de `"255.255.255.255"`, então um endereço válido e um erro ficam iguais
- O `inet_ntoa` devolve um ponteiro para um buffer estático interno, sobrescrito a cada chamada, o que quebra com duas chamadas no mesmo `printf` e com threads
- `inet_pton` e `inet_ntop` substituem as duas sem nenhum desses problemas

---

**Alternativa sem arpa/inet.h: getaddrinfo**

O `getaddrinfo` do `netdb.h` recebe o IP (ou um nome, como `"exemplo.com"`) e a porta como texto, e devolve a `struct sockaddr` já pronta, fazendo sozinho o trabalho do `inet_pton` e do `htons`:

```c
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>

struct addrinfo hints = {0};
struct addrinfo *res;
hints.ai_family = AF_UNSPEC;      // IPv4 ou IPv6, o que existir
hints.ai_socktype = SOCK_STREAM;  // TCP

if (getaddrinfo("127.0.0.1", "8080", &hints, &res) == 0) {
  int fd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
  connect(fd, res->ai_addr, res->ai_addrlen);  // sem montar sockaddr_in à mão
  freeaddrinfo(res);
  /* ... */
  close(fd);
}
```

- Funciona igual para IPv4, IPv6 e nomes, sem o código precisar saber qual dos três recebeu
- No servidor, `AI_PASSIVE` com o host `NULL` equivale a `INADDR_ANY` (ver `functions/netdb/getaddrinfo.md`)
- O `getnameinfo` faz o caminho inverso, de `struct sockaddr` para IP e porta em texto, substituindo o `inet_ntop` com o `ntohs`

---

**Comparando com Python e Rust**

- Em Python, o módulo `socket` junta em um só lugar o que no C está espalhado em vários headers: `socket.htons`, `socket.inet_pton` e `socket.getaddrinfo` existem dentro dele. Ao chamar `s.bind(("127.0.0.1", 8080))`, a conversão do IP em texto para binário e da porta para a ordem da rede acontece sozinha
- Em Rust, o `std::net` faz o mesmo papel: `"127.0.0.1:8080".parse::<SocketAddr>()` faz o trabalho do `inet_pton` com o `htons`, e o `TcpListener::bind` monta a struct de endereço por dentro
- Em C nada fica escondido: a struct de endereço é montada à mão e cada conversão é uma chamada explícita, por isso as funções de conversão aparecem como um header separado

Docs das funções deste header:

- `functions/inet/htons.md`: porta do host para a ordem da rede
- `functions/inet/ntohs.md`: porta da ordem da rede para o host
- `functions/inet/inet_pton.md`: IP em texto para binário
- `functions/inet/inet_ntop.md`: IP em binário para texto

> A `arpa/inet.h` é uma caixa de ferramentas de conversão, e não a API de sockets. O que é obrigatório para hospedar um servidor TCP ou UDP é o `sys/socket.h` (as funções), o `netinet/in.h` (a `struct sockaddr_in`) e o `unistd.h` (o `close`). Ela só entra quando um IP precisa virar texto ou sair de um texto, e mesmo isso pode ser feito pelo `getaddrinfo` e pelo `getnameinfo`
