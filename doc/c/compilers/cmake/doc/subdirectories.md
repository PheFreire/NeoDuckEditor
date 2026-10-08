**Subdiretórios**

> organizar o projeto em vários CMakeLists.txt

Projetos maiores dividem o build em vários `CMakeLists.txt`, um por diretório. O arquivo raiz chama `add_subdirectory` para cada parte, e cada uma define os seus próprios targets. Os targets são globais, então uma biblioteca definida em `src/fila/` pode ser linkada em `app/` sem nenhuma configuração extra

```text
projeto/
├── CMakeLists.txt          # raiz: cmake_minimum_required, project, add_subdirectory
├── cmake/                  # módulos .cmake próprios
├── include/fila/fila.h     # headers públicos
├── src/
│   ├── CMakeLists.txt      # add_library(fila ...)
│   └── fila.c
├── app/
│   ├── CMakeLists.txt      # add_executable(app ...)
│   └── main.c
└── tests/
    ├── CMakeLists.txt      # add_test(...)
    └── test_fila.c
```

```cmake
# CMakeLists.txt (raiz)
cmake_minimum_required(VERSION 3.20)
project(fila VERSION 1.0.0 LANGUAGES C)

add_subdirectory(src)
add_subdirectory(app)

if(PROJECT_IS_TOP_LEVEL)
    enable_testing()
    add_subdirectory(tests)
endif()
```

```cmake
# src/CMakeLists.txt
add_library(fila fila.c)
target_include_directories(fila PUBLIC ${PROJECT_SOURCE_DIR}/include)
```

```cmake
# app/CMakeLists.txt
add_executable(app main.c)
target_link_libraries(app PRIVATE fila)
```

---

**`add_subdirectory`**

```cmake
add_subdirectory(src)                          # build em build/src
add_subdirectory(externo/fila fila_build)      # diretório fora da árvore precisa de um binary dir
add_subdirectory(exemplos EXCLUDE_FROM_ALL)    # só compila se pedir o target explicitamente
add_subdirectory(externo/lib SYSTEM)           # includes como -isystem, sem warnings (3.25+)
```

- O `CMakeLists.txt` do subdiretório é executado **naquele momento**, em um escopo novo que herda uma cópia das variáveis (ver `variables.md`)
- O diretório de build espelha o do código: os arquivos de `src/` são gerados em `build/src/`
- Um target pode ser usado em `target_link_libraries` antes de ser criado: os nomes só são resolvidos no generate

---

**Variáveis de caminho**

| Variável | Aponta para |
|---|---|
| `CMAKE_SOURCE_DIR` | raiz do código do build inteiro (o `-S`) |
| `CMAKE_BINARY_DIR` | raiz do diretório de build (o `-B`) |
| `PROJECT_SOURCE_DIR` | diretório do último `project()` chamado |
| `PROJECT_BINARY_DIR` | diretório de build do último `project()` |
| `CMAKE_CURRENT_SOURCE_DIR` | diretório do `CMakeLists.txt` sendo processado |
| `CMAKE_CURRENT_BINARY_DIR` | diretório de build correspondente |
| `CMAKE_CURRENT_LIST_DIR` | diretório do arquivo sendo processado (também em `.cmake` incluídos) |

- Prefira `PROJECT_SOURCE_DIR` e `CMAKE_CURRENT_SOURCE_DIR` a `CMAKE_SOURCE_DIR`. Se o projeto for incluído por outro (via `add_subdirectory` ou `FetchContent`), `CMAKE_SOURCE_DIR` aponta para a raiz do **outro** projeto
- `PROJECT_IS_TOP_LEVEL` (3.21+) é verdadeiro só quando o projeto é o principal. Útil para não compilar testes e exemplos quando ele é usado como dependência

---

**include vs `add_subdirectory`**

```cmake
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(Avisos)                  # executa cmake/Avisos.cmake
include(cmake/Opcoes.cmake)      # por caminho
```

| | `add_subdirectory` | `include` |
|---|---|---|
| Recebe | um diretório com `CMakeLists.txt` | um arquivo `.cmake` |
| Escopo | novo | o de quem chamou |
| Diretório de build | novo (`build/dir`) | o mesmo |
| `CMAKE_CURRENT_SOURCE_DIR` | o subdiretório | não muda |
| Uso | partes do projeto com targets | funções, opções e configuração compartilhadas |

- Dentro de um arquivo incluído, `CMAKE_CURRENT_SOURCE_DIR` continua apontando para quem incluiu. Para o diretório do próprio `.cmake`, use `CMAKE_CURRENT_LIST_DIR`

---

**Listando arquivos**

```cmake
# explícito (recomendado)
add_library(fila
    fila.c
    no.c
    iterador.c
)

# glob
file(GLOB FONTES CONFIGURE_DEPENDS src/*.c)
add_library(fila ${FONTES})
```

- O `file(GLOB)` roda só no configure. Sem `CONFIGURE_DEPENDS`, um `.c` novo não é compilado até alguém rodar o `cmake` de novo
- `CONFIGURE_DEPENDS` faz o build conferir o glob a cada execução, o que deixa builds grandes mais lentos
- `GLOB_RECURSE` busca também nos subdiretórios

> A recomendação oficial do CMake é listar os fontes explicitamente: o diff do `CMakeLists.txt` mostra quais arquivos entraram ou saíram do build, e arquivos temporários esquecidos no diretório nunca são compilados por acidente
