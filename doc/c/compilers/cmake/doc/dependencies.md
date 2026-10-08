**Dependências**

> `find_package`, pkg-config, `find_library` e FetchContent

Uma dependência externa pode chegar ao projeto de dois jeitos: **já instalada** no sistema (encontrada com `find_package`, `pkg-config` ou `find_library`) ou **baixada e compilada junto** com o projeto (`FetchContent` ou `add_subdirectory`). Em todos os casos, o objetivo é terminar com um target que pode ser passado para `target_link_libraries`

```cmake
find_package(Threads REQUIRED)
target_link_libraries(app PRIVATE Threads::Threads)
```

---

**`find_package`**

```cmake
find_package(Fila)                         # opcional, define Fila_FOUND
find_package(Fila 1.2 REQUIRED)            # versão mínima, erro se não achar
find_package(Fila 1.2 EXACT REQUIRED)      # versão exata
find_package(Fila REQUIRED COMPONENTS core io)   # partes específicas do pacote
find_package(Fila CONFIG REQUIRED)         # só procura no modo config
find_package(Fila QUIET)                   # não imprime nada se não achar

if(Fila_FOUND)
    target_link_libraries(app PRIVATE Fila::fila)
endif()
```

- Cria targets importados (como `Fila::fila`) com a biblioteca, os includes e as dependências já configurados
- O resultado fica no cache: se não achou, configure de novo com o caminho certo ou com `--fresh`

---

**Modo module e modo config**

```text
find_package(Fila)
  │
  ├─ modo module   procura FindFila.cmake em CMAKE_MODULE_PATH
  │                e nos módulos que vêm com o CMake
  │                (script que procura os arquivos "na mão")
  │
  └─ modo config   procura FilaConfig.cmake ou fila-config.cmake
                   instalado pela própria biblioteca
                   em CMAKE_PREFIX_PATH, Fila_DIR, Fila_ROOT e prefixos do sistema
```

- **module**: o CMake traz `Find` modules para bibliotecas comuns do sistema (`Threads`, `PkgConfig` e vários outros). Lista completa em `cmake --help-module-list`
- **config**: a própria biblioteca instala um `Config.cmake` em `lib/cmake/Fila/`. É o formato que bibliotecas feitas com CMake geram (ver `packages.md`)
- Se não especificado, tenta module primeiro e depois config

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=/opt/fila         # prefixo onde a lib foi instalada
cmake -S . -B build -DCMAKE_PREFIX_PATH="/opt/a;/opt/b"   # vários prefixos
cmake -S . -B build -DFila_DIR=/opt/fila/lib/cmake/Fila   # diretório exato do Config.cmake
```

- No macOS com Homebrew, `/opt/homebrew` já faz parte dos prefixos padrão quando o `cmake` também vem do Homebrew

---

**Threads e math**

```cmake
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(app PRIVATE Threads::Threads)   # -pthread

target_link_libraries(app PRIVATE m)                  # -lm
```

- `THREADS_PREFER_PTHREAD_FLAG` faz o CMake usar `-pthread` em vez de `-lpthread` (ver `compilers/gcc/cheatsheet/flags.md`)
- A `libm` não tem um `find_package`. No macOS ela faz parte da `libSystem`, e passar `m` também funciona. Para não depender disso: `if(UNIX AND NOT APPLE)` antes do `target_link_libraries`

---

**pkg-config**

```cmake
find_package(PkgConfig REQUIRED)
pkg_check_modules(FILA REQUIRED IMPORTED_TARGET fila>=1.2)
target_link_libraries(app PRIVATE PkgConfig::FILA)
```

- Muitas bibliotecas de C instalam um `.pc` em vez de um `Config.cmake`. O `pkg_check_modules` lê esse arquivo com o `pkg-config`
- `IMPORTED_TARGET` cria o target `PkgConfig::FILA` com includes, flags e bibliotecas. Sem ele, só são criadas variáveis (`FILA_INCLUDE_DIRS`, `FILA_LIBRARIES`, `FILA_LDFLAGS`)
- O primeiro argumento (`FILA`) é o prefixo escolhido para os nomes. O último (`fila`) é o nome do `.pc`
- O `pkg-config` procura os `.pc` em `PKG_CONFIG_PATH` e também em `CMAKE_PREFIX_PATH/lib/pkgconfig`

---

**`find_library` e `find_path`**

```cmake
find_library(FILA_LIB NAMES fila PATHS /opt/fila/lib)
find_path(FILA_INCLUDE fila.h PATHS /opt/fila/include)

if(NOT FILA_LIB OR NOT FILA_INCLUDE)
    message(FATAL_ERROR "fila não encontrada")
endif()

target_link_libraries(app PRIVATE ${FILA_LIB})
target_include_directories(app PRIVATE ${FILA_INCLUDE})
```

- Último recurso, para bibliotecas sem `Config.cmake` e sem `.pc`
- O resultado fica no cache. Se não achar, a variável vale `FILA_LIB-NOTFOUND` (que é falsa em um `if`)
- Para reaproveitar em vários lugares, transforme isso em um `FindFila.cmake` (ver `modules.md`)

---

**FetchContent**

```cmake
include(FetchContent)

FetchContent_Declare(fila
    GIT_REPOSITORY https://example.com/fila.git
    GIT_TAG        v1.2.0
)
FetchContent_Declare(pilha
    URL      https://example.com/pilha-2.0.tar.gz
    URL_HASH SHA256=3b5c...
)
FetchContent_MakeAvailable(fila pilha)

target_link_libraries(app PRIVATE fila pilha)
```

- Baixa o código no **configure**, dentro de `build/_deps/`, e chama `add_subdirectory` nele. Os targets da dependência viram targets do projeto
- Fixe sempre uma versão (`GIT_TAG` com tag ou hash de commit, `URL_HASH`). Usar o nome de um branch torna o build não reproduzível
- `FIND_PACKAGE_ARGS` (3.24+) dentro do `FetchContent_Declare` tenta primeiro um `find_package` e só baixa se não encontrar
- `-DFETCHCONTENT_FULLY_DISCONNECTED=ON` impede novos downloads (útil sem internet, depois do primeiro configure)
- `-DFETCHCONTENT_SOURCE_DIR_FILA=/caminho/local` usa uma cópia local no lugar do download

---

**Código dentro do repositório**

```cmake
add_subdirectory(externo/fila EXCLUDE_FROM_ALL SYSTEM)
target_link_libraries(app PRIVATE fila)
```

- O código da dependência fica copiado no repositório (ou como `git submodule`) e é compilado como parte do projeto
- `EXCLUDE_FROM_ALL` compila só os targets da dependência que o projeto realmente usa
- `SYSTEM` (3.25+) evita que warnings nos headers da dependência apareçam no seu build

> Ordem de preferência: `find_package` com um `Config.cmake` da própria biblioteca, depois `pkg-config`, depois um `Find` module e, por último, `find_library` solto. `FetchContent` é ideal para dependências pequenas ou para garantir uma versão exata, mas recompila a dependência em cada diretório de build novo
