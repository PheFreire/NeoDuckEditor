**rmdir**

> `unistd.h`

O `rmdir` remove um diretório vazio, sendo a versão de `remove` especializada em diretórios

```c
#include <unistd.h>

int rmdir(const char *pathname);
```

- `pathname`: o caminho do diretório a ser removido

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro, por exemplo se o diretório não estiver vazio ou não existir

```c
rmdir("pasta_vazia");
```

