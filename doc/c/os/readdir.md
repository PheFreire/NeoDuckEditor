**readdir**

> `dirent.h`

O `readdir` lê a próxima entrada de um stream de diretório previamente aberto, avançando o cursor interno a cada chamada

```c
#include <dirent.h>

struct dirent *readdir(DIR *dirp);
```

- `dirp`: o stream de diretório retornado por `opendir`

- Retorna um ponteiro para a entrada atual, ou `NULL` quando não há mais entradas (fim da listagem) ou em caso de erro; o nome do arquivo/diretório fica no campo `d_name` da struct retornada
- As entradas incluem `.` (o próprio diretório) e `..` (o diretório pai), que precisam ser filtradas manualmente quando não forem desejadas
- O ponteiro retornado pode ser sobrescrito pela próxima chamada a `readdir` no mesmo stream, não devendo ser armazenado para uso posterior sem copiar seu conteúdo

```c
struct dirent *entry;
while ((entry = readdir(dir)) != NULL) {
    printf("%s\n", entry->d_name);
}
```

