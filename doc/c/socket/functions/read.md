**read**

> `unistd.h`

O `read`, quando usado sobre um descritor de socket, recebe dados de uma conexão já estabelecida, funcionando como um `recv` sem suporte a flags

```c
#include <unistd.h>

ssize_t read(int fd, void *buf, size_t count);
```

- `fd`: o descritor do socket conectado de onde os dados serão lidos
- `buf`: o buffer onde os dados recebidos serão copiados
- `count`: o tamanho máximo, em bytes, que `buf` pode receber

- Retorna quantos bytes foram de fato lidos, `0` se o outro lado fechou a conexão de forma ordenada, ou `-1` em caso de erro
- Assim como `write`, funciona sobre um socket por ele ser apenas mais um `fd`; não há como passar `flags` de rede como `MSG_PEEK`, sendo necessário usar `recv` quando isso for preciso

```c
char buffer[1024] = {0};
read(client_fd, buffer, sizeof(buffer));
```

