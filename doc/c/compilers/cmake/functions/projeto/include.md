**include**

> comando nativo do CMake, não precisa de include

O `include` executa um arquivo `.cmake` ou um módulo do CMake no ponto em que é chamado, no mesmo escopo de quem chamou, sendo usado para carregar módulos do CMake e compartilhar funções e configurações entre os `CMakeLists.txt`

```cmake
include(<arquivo|módulo> [OPTIONAL])
```

- `arquivo`: o caminho de um `.cmake`, como `cmake/Avisos.cmake`
- `módulo`: um nome sem extensão, procurado nos diretórios de `CMAKE_MODULE_PATH` e nos módulos que vêm com o CMake (`FetchContent`, `CTest`, `GNUInstallDirs`)
- `OPTIONAL`: não dá erro se o arquivo não existir

- Diferente do `add_subdirectory`, não cria escopo nem diretório de build novo. Variáveis e funções definidas no arquivo continuam visíveis depois dele
- Dentro do arquivo incluído, `CMAKE_CURRENT_SOURCE_DIR` continua sendo o de quem incluiu. O diretório do próprio `.cmake` está em `CMAKE_CURRENT_LIST_DIR`

```text
projeto/
├── CMakeLists.txt
└── cmake/
    └── Avisos.cmake
```

```cmake
# cmake/Avisos.cmake
function(ativar_avisos target)
    target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic)
endfunction()
```

```cmake
# CMakeLists.txt
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
include(Avisos)            # executa cmake/Avisos.cmake
include(FetchContent)      # módulo que vem com o CMake

add_executable(app main.c)
ativar_avisos(app)
```
