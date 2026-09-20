**rename**

> `stdio.h`

O `rename` renomeia ou move um arquivo/diretório de um caminho para outro

```c
#include <stdio.h>

int rename(const char *oldpath, const char *newpath);
```

- `oldpath`: o caminho atual do arquivo/diretório
- `newpath`: o novo caminho/nome desejado

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- Se `oldpath` e `newpath` estiverem no mesmo sistema de arquivos, a operação é feita apenas atualizando metadados, sem copiar dados; se estiverem em sistemas de arquivos diferentes, a chamada falha, sendo necessário implementar a movimentação manualmente (copiar o conteúdo para o novo caminho e depois apagar o original)
- Equivalente ao comando `mv` do shell

```c
rename("antigo.txt", "novo.txt");
```

