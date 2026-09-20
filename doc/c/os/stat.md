**stat**

> `sys/stat.h`

O `stat` obtém metadados sobre um arquivo ou diretório, preenchendo uma struct com informações como tipo, tamanho, permissões e datas de modificação

```c
#include <sys/stat.h>

int stat(const char *pathname, struct stat *statbuf);
```

- `pathname`: o caminho do arquivo/diretório a ser consultado
- `statbuf`: a estrutura onde os metadados serão escritos, incluindo o campo `st_mode`, que guarda o tipo do arquivo e suas permissões

- Retorna `0` em caso de sucesso, preenchendo `statbuf`, ou `-1` em caso de erro, por exemplo se o caminho não existir
- `S_ISREG(statbuf.st_mode)` verifica se é um arquivo regular
- `S_ISDIR(statbuf.st_mode)` verifica se é um diretório
- Se `pathname` for um link simbólico, `stat` segue o link e reporta sobre o alvo; para inspecionar o link em si, sem seguir, existe a variante `lstat`

```c
struct stat info;
if (stat("arquivo.txt", &info) == 0) {
    if (S_ISREG(info.st_mode)) {
        printf("é um arquivo\n");
    } else if (S_ISDIR(info.st_mode)) {
        printf("é um diretório\n");
    }
}
```

