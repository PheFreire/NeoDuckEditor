**Propriedades**

> o modelo de dados por trás dos targets

Tudo que um target sabe sobre si mesmo é guardado em `propriedades`: os fontes, os includes, as flags, o padrão de C, o nome do arquivo de saída. Os comandos `target_*` são atalhos que escrevem nessas propriedades. Além de targets, também têm propriedades os diretórios, os arquivos fonte, os testes, as entradas do cache e o projeto como um todo (global)

```cmake
set_target_properties(app PROPERTIES
    OUTPUT_NAME meu_app
    C_STANDARD 17
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin
)
get_target_property(fontes app SOURCES)
message(STATUS "Fontes do app: ${fontes}")
```

---

**Ler e escrever**

```cmake
set_target_properties(alvo1 alvo2 PROPERTIES PROP1 v1 PROP2 v2)   # vários targets e propriedades
set_property(TARGET app PROPERTY C_STANDARD 17)                   # forma genérica
set_property(TARGET app APPEND PROPERTY COMPILE_DEFINITIONS A)    # adiciona a uma lista
get_target_property(var app C_STANDARD)                           # var = 17 ou var-NOTFOUND
get_property(var TARGET app PROPERTY C_STANDARD)                  # forma genérica

set_property(SOURCE lento.c PROPERTY COMPILE_OPTIONS -O3)
set_property(DIRECTORY PROPERTY ADDITIONAL_CLEAN_FILES gerado.txt)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_tests_properties(fila PROPERTIES TIMEOUT 5)
```

- `set_target_properties` substitui o valor. `set_property(... APPEND ...)` adiciona à lista existente
- `get_target_property` falha se o target não existir. Antes, confira com `if(TARGET app)`

---

**Requisitos de uso como propriedades**

```text
target_include_directories(fila PRIVATE   src)       → INCLUDE_DIRECTORIES += src
target_include_directories(fila INTERFACE include)   → INTERFACE_INCLUDE_DIRECTORIES += include
target_include_directories(fila PUBLIC    include)   → os dois
```

| Para o próprio target | Para quem o usa |
|---|---|
| `INCLUDE_DIRECTORIES` | `INTERFACE_INCLUDE_DIRECTORIES` |
| `COMPILE_DEFINITIONS` | `INTERFACE_COMPILE_DEFINITIONS` |
| `COMPILE_OPTIONS` | `INTERFACE_COMPILE_OPTIONS` |
| `COMPILE_FEATURES` | `INTERFACE_COMPILE_FEATURES` |
| `LINK_LIBRARIES` | `INTERFACE_LINK_LIBRARIES` |
| `LINK_OPTIONS` | `INTERFACE_LINK_OPTIONS` |

- `PRIVATE`, `PUBLIC` e `INTERFACE` (ver `targets.md`) são só a escolha de qual coluna recebe o valor
- No generate, o CMake percorre o grafo de `LINK_LIBRARIES` e junta as propriedades `INTERFACE_*` de cada dependência às propriedades do target

---

**Valores iniciais**

```cmake
set(CMAKE_C_STANDARD 17)        # C_STANDARD = 17 nos targets criados a partir daqui
add_executable(app main.c)      # app.C_STANDARD = 17
set(CMAKE_C_STANDARD 11)
add_executable(outro outro.c)   # outro.C_STANDARD = 11, app continua 17
```

- Muitas propriedades são inicializadas a partir de uma variável `CMAKE_<PROPRIEDADE>` no momento em que o target é criado
- Mudar a variável depois não altera targets que já existem

---

**Propriedades de target úteis**

- `OUTPUT_NAME`: nome do arquivo gerado, sem prefixo nem extensão
- `PREFIX` / `SUFFIX`: prefixo (`lib`) e extensão do arquivo gerado
- `RUNTIME_OUTPUT_DIRECTORY`, `LIBRARY_OUTPUT_DIRECTORY`, `ARCHIVE_OUTPUT_DIRECTORY`: onde o arquivo é gerado
- `C_STANDARD`, `C_STANDARD_REQUIRED`, `C_EXTENSIONS`: padrão de C (ver `compiler-flags.md`)
- `POSITION_INDEPENDENT_CODE`: `-fPIC`
- `INTERPROCEDURAL_OPTIMIZATION`: LTO
- `C_VISIBILITY_PRESET`: `-fvisibility=`
- `VERSION` / `SOVERSION`: versões de uma biblioteca compartilhada (ver `libraries.md`)
- `INSTALL_RPATH`, `BUILD_RPATH`: rpath gravado no binário
- `COMPILE_WARNING_AS_ERROR`: `-Werror` (3.24+)
- `EXCLUDE_FROM_ALL`: o target não é compilado pelo `all`
- `LINKER_LANGUAGE`: qual driver faz o link (`C` ou `CXX`)
- `TYPE`: `EXECUTABLE`, `STATIC_LIBRARY`, `SHARED_LIBRARY`... (somente leitura)
- `IMPORTED_LOCATION`: caminho do arquivo de um target importado

---

**Propriedades próprias**

```cmake
define_property(TARGET PROPERTY FILA_PLUGIN
    BRIEF_DOCS "Target é um plugin da fila")
set_property(TARGET meu_plugin PROPERTY FILA_PLUGIN ON)

get_property(eh_plugin TARGET meu_plugin PROPERTY FILA_PLUGIN)
```

- Qualquer nome pode ser usado como propriedade, mesmo sem `define_property`. Ele só documenta e permite herança de valores
- Útil para funções do projeto que precisam marcar targets e depois procurá-los

---

**Inspecionar**

```cmake
include(CMakePrintHelpers)
cmake_print_properties(TARGETS app fila PROPERTIES
    TYPE INCLUDE_DIRECTORIES INTERFACE_INCLUDE_DIRECTORIES LINK_LIBRARIES)

get_property(todos DIRECTORY ${PROJECT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
```

```bash
cmake --help-property-list | less     # todas as propriedades conhecidas
```

- `BUILDSYSTEM_TARGETS` lista os targets criados em um diretório (não inclui os subdiretórios)

> O valor lido com `get_target_property` é o valor **cru**, antes do generate: ele pode conter generator expressions e não inclui o que vem das dependências. Para ver o resultado final que chega ao compilador, use `cmake --build build -v` ou o `compile_commands.json` (ver `debugging.md`)
