**opendir**

> `dirent.h`

O `opendir` abre um diretório para leitura, retornando um stream que será usado para percorrer suas entradas

```c
#include <dirent.h>

DIR *opendir(const char *name);
```

- `name`: o caminho do diretório a ser aberto

- Retorna um ponteiro para o stream do diretório, ou `NULL` em caso de erro (diretório inexistente, sem permissão, etc)
- O stream retornado é passado para `readdir` a cada leitura e, ao final, deve ser fechado com `closedir`

```c
DIR *dir = opendir(".");
if (dir != NULL) {
    // usar dir com readdir
}
```

