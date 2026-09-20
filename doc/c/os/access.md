**access**

`> unistd.h`

O `access` verifica se um arquivo ou diretório existe e/ou se o processo atual tem determinada permissão sobre ele

```c
#include <unistd.h>

int access(const char *pathname, int mode);
```

- `pathname`: o caminho a ser verificado
- `mode`: quais permissões checar, podendo ser `F_OK` (apenas existência) ou uma combinação de `R_OK`, `W_OK` e `X_OK` (leitura, escrita e execução)

- Retorna `0` se o caminho existe e satisfaz o `mode` pedido, ou `-1` caso contrário
- Para checar apenas se o caminho existe, sem se importar com permissões, usa-se `F_OK`

```c
if (access("arquivo.txt", F_OK) == 0) {
    printf("arquivo existe\n");
}
```

> Existe uma janela de tempo entre o `access` e o uso real do arquivo (TOCTOU - time-of-check to time-of-use) onde ele pode ser removido ou ter suas permissões alteradas; por isso, para abrir um arquivo, geralmente é mais seguro tentar abrir diretamente e tratar o erro do que checar a existência antes


