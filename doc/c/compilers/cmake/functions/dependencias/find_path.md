**find_path**

> comando nativo do CMake, não precisa de include

O `find_path` procura o diretório que contém um arquivo, normalmente um header, e grava esse diretório em uma variável para ser passado ao `target_include_directories`

```cmake
find_path(<variável> NAMES <arquivo>... [PATHS <diretório>...] [PATH_SUFFIXES <sufixo>...] [REQUIRED])
find_path(<variável> <arquivo>)
```

- `variável`: recebe o **diretório** onde o arquivo está, ou `<variável>-NOTFOUND`
- `arquivo`: o nome do header, como `fila.h`, ou um caminho parcial, como `fila/fila.h`
- `PATHS`: diretórios extras para procurar
- `PATH_SUFFIXES`: subdiretórios testados dentro de cada diretório de busca, como `fila`
- `REQUIRED` (3.18+): para o configure com erro se não encontrar

- Devolve o diretório, e não o caminho do arquivo. Com `NAMES fila/fila.h`, o resultado é o diretório que contém `fila/`, e o código inclui `"fila/fila.h"`
- Como o `find_library`, grava o resultado no cache

```cmake
find_path(FILA_INCLUDE NAMES fila/fila.h REQUIRED)    # /usr/local/include
target_include_directories(app PRIVATE ${FILA_INCLUDE})
```

```c
#include "fila/fila.h"
```
