**Includes**

> como fazer headers e arquivos .c de outros diretórios chegarem ao build

Um header e um `.c` em outro diretório precisam de duas coisas diferentes no CMake. O **`.c`** precisa ser compilado e linkado, então tem que entrar na lista de fontes de algum target. O **`.h`** precisa ser encontrado pelo preprocessor, então o diretório dele tem que estar nos caminhos de busca (`-I`), configurados com `target_include_directories`. Faltar o primeiro dá `undefined reference` no link. Faltar o segundo dá `No such file or directory` na compilação

```text
src/lista/lista.c  →  add_executable / add_library   →  compilado e linkado
src/lista/lista.h  →  target_include_directories     →  -I no comando do gcc
```

> Como o `#include` procura os arquivos está em `compilers/gcc/doc/preprocessor.md`

---

**Como o gcc procura o header**

```c
#include "lista.h"     // 1. diretório do arquivo que tem o #include
                       // 2. diretórios do -I, na ordem
                       // 3. diretórios do sistema
#include <stdio.h>     // só 2 e 3
```

- O `target_include_directories` só adiciona diretórios ao passo 2. O caminho escrito no `#include` é relativo a cada um desses diretórios
- Com aspas, o diretório do próprio arquivo vem antes de tudo. Por isso um `#include "lista.h"` funciona sem nenhuma configuração quando o `.h` está ao lado do `.c` que o inclui
- O que vai entre aspas é o caminho a partir de um desses diretórios: com `-Isrc`, o header `src/lista/lista.h` é incluído como `"lista/lista.h"`

---

**main.c e módulo dentro de src**

```text
projeto/
├── CMakeLists.txt
└── src/
    ├── main.c
    └── lista/
        ├── lista.h
        └── lista.c
```

```cmake
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)

add_executable(app
    src/main.c
    src/lista/lista.c
)
target_include_directories(app PRIVATE src)
```

```c
// src/main.c
#include "lista/lista.h"

// src/lista/lista.c
#include "lista/lista.h"
```

```text
gcc -I/home/u/projeto/src -c src/main.c
gcc -I/home/u/projeto/src -c src/lista/lista.c
gcc main.c.o lista.c.o -o app
```

- Todo `.c` do projeto entra no `add_executable`. Headers não precisam estar na lista
- Os caminhos relativos do `CMakeLists.txt` partem do diretório onde ele está (`CMAKE_CURRENT_SOURCE_DIR`)
- Com `-Isrc`, todos os arquivos incluem o header pelo mesmo caminho (`"lista/lista.h"`), não importa em qual diretório estejam

---

**Qual diretório passar para o -I**

| `target_include_directories` | `#include` | Vantagem |
|---|---|---|
| `src` | `"lista/lista.h"` | o nome do módulo aparece no include e evita colisões |
| `src/lista` | `"lista.h"` | include curto |
| `src` e `src/lista` | os dois funcionam | evite, cada arquivo acaba usando um estilo |

- Com `-Isrc/lista`, dois módulos com um header de mesmo nome (`src/lista/util.h` e `src/fila/util.h`) colidem: o primeiro `-I` da lista vence
- Com `-Isrc`, `"lista/util.h"` e `"fila/util.h"` são arquivos diferentes, sem ambiguidade
- Escolha um estilo e use em todo o projeto

---

**Módulo como biblioteca**

```text
projeto/
├── CMakeLists.txt
└── src/
    ├── main.c
    └── lista/
        ├── CMakeLists.txt
        ├── lista.h
        └── lista.c
```

```cmake
# CMakeLists.txt (raiz)
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)

add_subdirectory(src/lista)

add_executable(app src/main.c)
target_link_libraries(app PRIVATE lista)
```

```cmake
# src/lista/CMakeLists.txt
add_library(lista STATIC lista.c)
target_include_directories(lista PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
```

```c
// src/main.c
#include "lista.h"
```

- O módulo declara os próprios fontes e o próprio diretório de headers. O `app` só diz que usa a `lista`
- O include é `PUBLIC`, então o `-Isrc/lista` chega ao `app` automaticamente pelo `target_link_libraries` (ver `targets.md`)
- Adicionar um `.c` novo ao módulo mexe só no `src/lista/CMakeLists.txt`
- Para incluir como `"lista/lista.h"`, troque o include para `PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..`

---

**Vários módulos**

```text
src/
├── main.c
├── lista/   CMakeLists.txt, lista.h, lista.c
├── fila/    CMakeLists.txt, fila.h, fila.c        (fila usa lista)
└── util/    CMakeLists.txt, util.h, util.c
```

```cmake
# CMakeLists.txt (raiz)
add_subdirectory(src/util)
add_subdirectory(src/lista)
add_subdirectory(src/fila)

add_executable(app src/main.c)
target_link_libraries(app PRIVATE fila util)
```

```cmake
# src/fila/CMakeLists.txt
add_library(fila STATIC fila.c)
target_include_directories(fila PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(fila PUBLIC lista)
```

- `fila` linka `lista` como `PUBLIC` porque `fila.h` inclui `lista.h`. Assim o `app` também recebe o `-I` da `lista` sem pedir
- Se `lista.h` fosse incluído só em `fila.c`, o certo seria `PRIVATE`, e o `app` não enxergaria `lista.h`
- A ordem dos `add_subdirectory` não importa para o `target_link_libraries`: os nomes dos targets só são resolvidos no generate

---

**Headers públicos e privados**

```text
src/lista/
├── CMakeLists.txt
├── include/lista/lista.h     público: usado por quem linka a lista
├── lista_interno.h           privado: só para os .c da lista
└── lista.c
```

```cmake
add_library(lista STATIC lista.c)
target_include_directories(lista
    PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)
```

```c
// src/main.c
#include "lista/lista.h"        // ok
#include "lista_interno.h"      // erro: No such file or directory
```

- Separar os headers garante que o resto do projeto só usa a API pública do módulo
- É a mesma organização de uma biblioteca instalada, com `include/` contendo só o que é público (ver `install.md`)

---

**Headers gerados**

```cmake
configure_file(versao.h.in ${CMAKE_CURRENT_BINARY_DIR}/versao.h @ONLY)
target_include_directories(app PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
```

- Headers criados pelo CMake ficam no diretório de **build**, então esse diretório também precisa ir para o `-I` (ver `custom-commands.md`)

---

**Conferir e corrigir**

```bash
cmake --build build -v        # mostra os -I de cada comando do gcc
```

- `fatal error: lista.h: No such file or directory`: o diretório do header não chegou ao `-I` daquele arquivo. Confira o `target_include_directories` e se ele é `PUBLIC` quando o header é usado por outro target
- `undefined reference to 'lista_criar'`: o header foi achado, mas o `.c` não está em nenhum target, ou o target da biblioteca não foi passado ao `target_link_libraries`
- Para o `clangd` no Neovim enxergar os mesmos includes, gere o `compile_commands.json` (ver `debugging.md`)

> Evite escrever caminhos relativos no próprio `#include`, como `#include "../lista/lista.h"`. Funciona, mas prende o código à posição atual dos diretórios e quebra quando um arquivo muda de lugar. Deixe o `CMakeLists.txt` dizer onde ficam os headers e mantenha os `#include` estáveis
