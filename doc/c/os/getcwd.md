**getcwd**

> `unistd.h`

O `getcwd` obtém o caminho absoluto do diretório de trabalho atual do processo

```c
#include <unistd.h>

char *getcwd(char *buf, size_t size);
```

- `buf`: o buffer onde o caminho será escrito
- `size`: o tamanho, em bytes, do buffer fornecido

- Retorna `buf` preenchido em caso de sucesso, ou `NULL` em caso de erro, por exemplo se `size` for pequeno demais para o caminho
- Se `buf` for `NULL`, algumas implementações (como a glibc) alocam dinamicamente um buffer do tamanho necessário, que precisa ser liberado com `free` depois de usado

```c
char cwd[1024];
if (getcwd(cwd, sizeof(cwd)) != NULL) {
    printf("cwd: %s\n", cwd);
}
```

