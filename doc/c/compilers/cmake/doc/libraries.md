**Bibliotecas**

> `add_library`: estática, compartilhada, object, module e interface

O `add_library` cria um target de biblioteca. O tipo decide se o código vai para dentro do executável (estática), fica em um arquivo carregado ao executar (compartilhada) ou nem é compilado (interface). O CMake cuida das flags que cada tipo exige (`ar`, `-fPIC`, `-shared` / `-dynamiclib`), então o mesmo `CMakeLists.txt` funciona no Linux e no macOS

```cmake
add_library(fila STATIC src/fila.c)       # libfila.a
add_library(fila SHARED src/fila.c)       # libfila.so / libfila.dylib
add_library(comum OBJECT src/comum.c)     # só os .o, sem arquivo de biblioteca
add_library(plugin MODULE src/plugin.c)   # carregado com dlopen, não linkável
add_library(util INTERFACE)               # header-only, nada é compilado
```

| Tipo | Linux | macOS | Uso |
|---|---|---|---|
| `STATIC` | `libfila.a` | `libfila.a` | código copiado para o executável |
| `SHARED` | `libfila.so` | `libfila.dylib` | carregada pelo loader ao executar |
| `MODULE` | `libplugin.so` | `libplugin.so` | plugin carregado com `dlopen` |
| `OBJECT` | `.o` | `.o` | reaproveitar objetos entre targets |
| `INTERFACE` | nenhum | nenhum | só headers e requisitos de uso |

> A diferença entre os tipos de biblioteca no nível do compilador está em `compilers/gcc/doc/libraries.md`

---

**`BUILD_SHARED_LIBS`**

```cmake
add_library(fila src/fila.c)   # sem tipo
```

```bash
cmake -S . -B build                          # STATIC (padrão)
cmake -S . -B build -DBUILD_SHARED_LIBS=ON   # SHARED
```

- Sem o tipo explícito, o `add_library` usa a variável `BUILD_SHARED_LIBS` para decidir
- É a forma recomendada para bibliotecas que outras pessoas vão usar: quem compila escolhe o tipo, sem editar o `CMakeLists.txt`
- Pode virar uma opção do projeto: `option(BUILD_SHARED_LIBS "Compila bibliotecas compartilhadas" OFF)`

---

**Bibliotecas compartilhadas**

```cmake
add_library(fila SHARED src/fila.c)
set_target_properties(fila PROPERTIES
    VERSION 1.2.0       # versão do arquivo
    SOVERSION 1         # versão da ABI
    C_VISIBILITY_PRESET hidden
)
```

```text
Linux:  libfila.so.1.2.0   arquivo real
        libfila.so.1       soname (gravado no executável)
        libfila.so         usado no link
macOS:  libfila.1.2.0.dylib, libfila.1.dylib, libfila.dylib
```

- `-fPIC` é adicionado automaticamente (propriedade `POSITION_INDEPENDENT_CODE`, ligada por padrão em `SHARED` e `MODULE`)
- Uma biblioteca `STATIC` que será linkada dentro de uma `SHARED` também precisa de PIC: `set_target_properties(fila PROPERTIES POSITION_INDEPENDENT_CODE ON)` ou `CMAKE_POSITION_INDEPENDENT_CODE ON` para todos os targets
- `C_VISIBILITY_PRESET hidden` compila com `-fvisibility=hidden`: só os símbolos marcados explicitamente são exportados (ver `modules.md` sobre `GenerateExportHeader`)

---

**RPATH**

O executável precisa encontrar a `.so`/`.dylib` ao rodar. O CMake grava caminhos de busca (`rpath`) no executável automaticamente

```cmake
# build: o CMake grava o caminho absoluto do diretório de build (automático)
# install: o rpath é removido por padrão. Para manter, defina antes de criar os targets:
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")           # Linux
set(CMAKE_INSTALL_RPATH "@loader_path/../lib")      # macOS
```

- No diretório de build, o executável roda direto, sem `LD_LIBRARY_PATH`
- Ao instalar, o CMake reescreve o rpath para o valor de `INSTALL_RPATH` (vazio por padrão). Sem configurar isso, o executável instalado só acha a biblioteca se ela estiver em um diretório padrão do sistema
- `$ORIGIN` (Linux) e `@loader_path` (macOS) significam "o diretório do próprio binário", então `../lib` funciona onde quer que o prefixo de instalação esteja
- No macOS, o `install name` da dylib é `@rpath/libfila.dylib` por padrão (`CMAKE_MACOSX_RPATH`)

---

**Biblioteca OBJECT**

```cmake
add_library(comum OBJECT src/log.c src/erro.c)
target_include_directories(comum PUBLIC include)

add_executable(app src/main.c)
add_executable(ferramenta src/ferramenta.c)
target_link_libraries(app PRIVATE comum)
target_link_libraries(ferramenta PRIVATE comum)
```

- Compila os `.c` uma única vez e coloca os `.o` diretamente em cada target que a usa, sem criar um `.a`
- Ao contrário de uma `STATIC`, **todos** os `.o` entram no executável, mesmo os que não resolvem nenhum símbolo
- Também é possível usar os objetos como fontes: `add_executable(app main.c $<TARGET_OBJECTS:comum>)`

---

**Biblioteca INTERFACE**

```cmake
add_library(util INTERFACE)
target_include_directories(util INTERFACE include)
target_compile_definitions(util INTERFACE UTIL_INLINE)

target_link_libraries(app PRIVATE util)
```

- Não compila nada e não gera arquivo. Só carrega requisitos de uso (`INTERFACE`) para quem a linka
- Serve para bibliotecas `header-only` (só `static inline` e macros) e para agrupar configurações, como um target `avisos` com as flags de warning do projeto (ver `compiler-flags.md`)

---

**Bibliotecas importadas**

```cmake
add_library(fila_externa STATIC IMPORTED)
set_target_properties(fila_externa PROPERTIES
    IMPORTED_LOCATION "/opt/fila/lib/libfila.a"
    INTERFACE_INCLUDE_DIRECTORIES "/opt/fila/include"
)
target_link_libraries(app PRIVATE fila_externa)
```

- Representa uma biblioteca que já existe pronta, fora do projeto. O CMake não a compila
- É o que o `find_package` cria por baixo dos panos ao encontrar um pacote (`Threads::Threads`, `PkgConfig::FILA`) (ver `dependencies.md`)

> O executável gerado com uma biblioteca `SHARED` funciona no diretório de build porque o CMake gravou o rpath absoluto. Se ele for copiado manualmente para outra máquina, a biblioteca não será encontrada. Para distribuir, use `install` com um `INSTALL_RPATH` relativo (ver `install.md`)
