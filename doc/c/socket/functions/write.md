**write**

> `unistd.h`

O `write`, quando usado sobre um descritor de socket, envia dados por uma conexão já estabelecida, funcionando como um `send` sem suporte a flags

```c
#include <unistd.h>

ssize_t write(int fd, const void *buf, size_t count);
```

- `fd`: o descritor do socket conectado por onde os dados serão enviados
- `buf`: o buffer contendo os dados a serem enviados
- `count`: quantos bytes de `buf` devem ser enviados

- Retorna quantos bytes foram de fato enviados, podendo ser menor que `count`, ou `-1` em caso de erro
- Como um socket é apenas mais um tipo de `fd`, as mesmas funções genéricas de I/O (`write`/`read`) funcionam sobre ele; a diferença para `send` é que este último aceita `flags` específicas de rede, úteis em casos mais avançados

```c
char *msg = "ola servidor";
write(sock_fd, msg, strlen(msg));
```

