**chdir**

> `unistd.h`

O `chdir` muda o diretório de trabalho atual do processo para o caminho informado

```c
#include <unistd.h>

int chdir(const char *path);
```

- `path`: o caminho do diretório para o qual o processo deve mudar

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro, por exemplo se o diretório não existir ou não houver permissão de acesso
- A mudança afeta apenas o processo atual (e os que ele futuramente criar via `fork`), não processos já em execução, como o shell que chamou o programa

```c
if (chdir("/tmp") == 0) {
    printf("mudou para /tmp\n");
}
```

