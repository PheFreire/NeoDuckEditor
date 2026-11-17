**set_target_properties**

> comando nativo do CMake, não precisa de include

O `set_target_properties` muda propriedades de um ou mais targets, como o nome do arquivo gerado, o diretório de saída, o padrão de C e a versão de uma biblioteca dinâmica

```cmake
set_target_properties(<target>... PROPERTIES <propriedade> <valor> [<propriedade> <valor>]...)
get_target_property(<variável> <target> <propriedade>)
```

- `target`: um ou mais targets já criados
- `propriedade` / `valor`: os pares a mudar (tabela abaixo)
- `get_target_property`: lê o valor de uma propriedade para uma variável

| Propriedade | O que faz |
|---|---|
| `OUTPUT_NAME` | nome do arquivo gerado, sem mudar o nome do target |
| `RUNTIME_OUTPUT_DIRECTORY` | diretório onde o executável é gerado |
| `ARCHIVE_OUTPUT_DIRECTORY` | diretório das bibliotecas `.a` |
| `LIBRARY_OUTPUT_DIRECTORY` | diretório das bibliotecas `.so` / `.dylib` |
| `C_STANDARD` | padrão de C só deste target |
| `C_EXTENSIONS` | `OFF` usa `-std=c17` no lugar de `-std=gnu17` |
| `VERSION` / `SOVERSION` | versão do arquivo e da ABI de uma `SHARED` |
| `POSITION_INDEPENDENT_CODE` | `ON` compila com `-fPIC` |

- Muitas propriedades começam com o valor de uma variável `CMAKE_<PROPRIEDADE>` no momento em que o target é criado. É por isso que `set(CMAKE_C_STANDARD 17)` precisa vir antes dos `add_executable`

```cmake
add_executable(app main.c)
set_target_properties(app PROPERTIES
    OUTPUT_NAME chat
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)
# gera build/bin/chat

add_library(lista SHARED lista.c)
set_target_properties(lista PROPERTIES VERSION 1.2.0 SOVERSION 1)
# no Linux gera liblista.so.1.2.0, liblista.so.1 e liblista.so
```
