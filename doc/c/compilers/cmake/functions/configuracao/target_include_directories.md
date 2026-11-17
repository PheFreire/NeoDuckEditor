**target_include_directories**

> comando nativo do CMake, não precisa de include

O `target_include_directories` adiciona diretórios onde o preprocessor procura os headers dos `#include` de um target, gerando as flags `-I` na compilação

```cmake
target_include_directories(<target> [SYSTEM] [BEFORE]
    <PRIVATE|PUBLIC|INTERFACE> <diretório>...
    [<PRIVATE|PUBLIC|INTERFACE> <diretório>...]
)
```

- `target`: o target que recebe os diretórios. Precisa ter sido criado antes
- `PRIVATE`: o diretório vale só para os `.c` do próprio target
- `PUBLIC`: vale para o target e para todo target que o linka
- `INTERFACE`: vale só para quem linka o target
- `diretório`: um ou mais diretórios, relativos ao `CMakeLists.txt` atual. Pode usar `${PROJECT_SOURCE_DIR}` para partir da raiz
- `SYSTEM`: usa `-isystem` no lugar de `-I`, sem mostrar os warnings desses headers
- `BEFORE`: coloca os diretórios antes dos que o target já tem

- Só recebe diretórios. Os `.h` não são listados em lugar nenhum
- O caminho escrito no `#include` é relativo a cada diretório. Com `-Isrc`, o arquivo `src/lista/lista.h` é incluído como `"lista/lista.h"`
- Um `#include` com aspas procura primeiro no diretório do próprio arquivo. Por isso um header ao lado do `.c` que o inclui funciona sem configurar nada
- Use `PUBLIC` para os headers que aparecem na API da biblioteca e `PRIVATE` para os internos

```text
src/lista/
├── CMakeLists.txt
├── include/lista/lista.h    público
├── lista_interno.h          privado
└── lista.c
```

```cmake
add_library(lista STATIC lista.c)
target_include_directories(lista
    PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

add_executable(app main.c)
target_link_libraries(app PRIVATE lista)     # o app recebe só o include PUBLIC
```

```c
// main.c
#include "lista/lista.h"       // ok
#include "lista_interno.h"     // erro: No such file or directory
```

> `fatal error: lista.h: No such file or directory` quer dizer que o diretório do header não chegou ao `-I` daquele arquivo. Confira com `cmake --build build -v` quais `-I` o comando do `gcc` recebeu
