**remove**

> `stdio.h`

O `remove` apaga um arquivo ou diretório vazio do sistema de arquivos

```c
#include <stdio.h>

int remove(const char *pathname);
```

- `pathname`: o caminho do arquivo ou diretório a ser removido

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- Internamente, chama `unlink` para arquivos e `rmdir` para diretórios, funcionando como uma versão genérica das duas operações
- Só remove diretórios vazios; para apagar uma árvore inteira de diretórios com conteúdo é preciso percorrer e remover cada entrada manualmente

```c
remove("arquivo.txt");
```

