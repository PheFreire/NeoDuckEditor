**Módulos**

> include, módulos padrão, scripts .cmake e Find modules próprios

Um módulo é um arquivo `.cmake` com funções, macros ou configurações, carregado com `include`. O CMake vem com dezenas de módulos prontos (checagens do sistema, instalação, testes, download de dependências), e um projeto pode ter os seus próprios em um diretório `cmake/`

```cmake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(GNUInstallDirs)      # módulo do CMake
include(Avisos)              # cmake/Avisos.cmake do projeto
```

- `include(Nome)` procura `Nome.cmake` em `CMAKE_MODULE_PATH` e depois nos módulos do CMake
- `include(caminho/arquivo.cmake)` carrega por caminho
- O arquivo roda no escopo de quem incluiu, como se o texto estivesse ali (ver `subdirectories.md`)

---

**Módulos padrão úteis**

| Módulo | Para |
|---|---|
| `GNUInstallDirs` | diretórios padrão de instalação (ver `install.md`) |
| `CTest` | testes e a opção `BUILD_TESTING` (ver `testing.md`) |
| `FetchContent` | baixar dependências no configure (ver `dependencies.md`) |
| `CMakePrintHelpers` | `cmake_print_variables` e `cmake_print_properties` |
| `CMakePackageConfigHelpers` | gerar `Config.cmake` e arquivo de versão (ver `packages.md`) |
| `GenerateExportHeader` | macros de visibilidade para bibliotecas compartilhadas |
| `CheckIPOSupported` | testar suporte a LTO |
| `CheckIncludeFile` | testar se um header existe |
| `CheckSymbolExists` | testar se uma função ou macro existe em um header |
| `CheckCSourceCompiles` | testar se um trecho de C compila |
| `CheckCCompilerFlag` | testar se o compilador aceita uma flag |
| `CMakeDependentOption` | opção que só existe se outra estiver ligada |
| `CPack` | gerar pacotes (ver `cpack.md`) |

---

**Checagens do sistema**

```cmake
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CheckCSourceCompiles)
include(CheckCCompilerFlag)

check_include_file(sys/epoll.h TEM_EPOLL)
check_symbol_exists(strlcpy "string.h" TEM_STRLCPY)
check_c_source_compiles("
    #include <stdatomic.h>
    int main(void) { atomic_int x = 0; return x; }
" TEM_ATOMIC)
check_c_compiler_flag(-fanalyzer TEM_FANALYZER)

if(TEM_FANALYZER)
    target_compile_options(app PRIVATE -fanalyzer)
endif()
```

- Cada resultado vira uma variável de cache (`1` ou vazio), que pode ir para um header com `#cmakedefine` (ver `custom-commands.md`)
- Funções que precisam de uma biblioteca extra: `set(CMAKE_REQUIRED_LIBRARIES m)` antes da checagem

---

**GenerateExportHeader**

```cmake
include(GenerateExportHeader)
add_library(fila SHARED src/fila.c)
set_target_properties(fila PROPERTIES C_VISIBILITY_PRESET hidden)
generate_export_header(fila)                 # gera build/fila_export.h
target_include_directories(fila PUBLIC ${CMAKE_CURRENT_BINARY_DIR})
```

```c
#include "fila_export.h"

FILA_EXPORT Fila *fila_criar(void);    // exportada
void fila_auxiliar(void);              // escondida
```

- Com `-fvisibility=hidden`, nenhuma função é exportada por padrão. A macro `FILA_EXPORT` marca as que fazem parte da API
- A mesma macro vira `__attribute__((visibility("default")))` no GCC/Clang e `__declspec(dllexport)`/`dllimport` no MSVC
- Para builds estáticos, defina `FILA_STATIC_DEFINE` para a macro ficar vazia

---

**Módulo próprio**

```cmake
# cmake/Avisos.cmake
include_guard(GLOBAL)

function(habilitar_avisos alvo)
    target_compile_options(${alvo} PRIVATE
        "$<$<C_COMPILER_ID:GNU,Clang,AppleClang>:-Wall;-Wextra;-Wpedantic>"
    )
endfunction()
```

```cmake
# CMakeLists.txt
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(Avisos)
habilitar_avisos(app)
```

- `include_guard(GLOBAL)` evita que o arquivo seja executado duas vezes, como um include guard do C
- Dentro do módulo, use `CMAKE_CURRENT_LIST_DIR` para achar arquivos ao lado dele

---

**Find module**

```cmake
# cmake/FindFila.cmake
find_path(Fila_INCLUDE_DIR NAMES fila.h PATH_SUFFIXES fila)
find_library(Fila_LIBRARY NAMES fila)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Fila
    REQUIRED_VARS Fila_LIBRARY Fila_INCLUDE_DIR
)

if(Fila_FOUND AND NOT TARGET Fila::fila)
    add_library(Fila::fila UNKNOWN IMPORTED)
    set_target_properties(Fila::fila PROPERTIES
        IMPORTED_LOCATION "${Fila_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${Fila_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(Fila_INCLUDE_DIR Fila_LIBRARY)
```

```cmake
find_package(Fila REQUIRED)
target_link_libraries(app PRIVATE Fila::fila)
```

- Ensina o `find_package` a encontrar uma biblioteca que não tem `Config.cmake` (modo module, ver `dependencies.md`)
- `find_package_handle_standard_args` define `Fila_FOUND`, imprime a mensagem de encontrado e trata `REQUIRED` e `QUIET`
- `UNKNOWN IMPORTED` serve para quando não se sabe se o arquivo é `.a` ou `.so`
- `mark_as_advanced` esconde as variáveis de `cmake -L`

---

**Scripts**

```cmake
# scripts/limpar.cmake
file(GLOB temporarios "${DIR}/*.tmp")
foreach(f IN LISTS temporarios)
    file(REMOVE "${f}")
    message(STATUS "Removido ${f}")
endforeach()
```

```bash
cmake -DDIR=build -P scripts/limpar.cmake
```

- Um `.cmake` executado com `-P` funciona como um script portátil, sem precisar de um projeto
- Usado como `COMMAND ${CMAKE_COMMAND} -P script.cmake` em `add_custom_command` para tarefas que seriam diferentes em bash e em PowerShell

> Antes de escrever uma checagem ou um Find module, procure em `cmake --help-module-list`: o CMake já tem módulos para a maioria das bibliotecas do sistema e das checagens comuns, e eles tratam casos de plataforma que um módulo escrito à mão normalmente esquece
