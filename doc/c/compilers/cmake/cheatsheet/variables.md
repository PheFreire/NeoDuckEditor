**Variáveis do CMake**

> referência rápida das variáveis predefinidas mais usadas

O CMake cria centenas de variáveis com informações sobre caminhos, compilador e plataforma, e lê outras para mudar o seu comportamento. As que começam com `CMAKE_` são reservadas: não crie variáveis próprias com esse prefixo

```cmake
message(STATUS "Compilador: ${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
message(STATUS "Sistema:    ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
```

---

**Caminhos** (ver `subdirectories.md`)

- `CMAKE_SOURCE_DIR` / `CMAKE_BINARY_DIR`: raiz do código e do build do projeto principal
- `PROJECT_SOURCE_DIR` / `PROJECT_BINARY_DIR`: raiz do último `project()`
- `CMAKE_CURRENT_SOURCE_DIR` / `CMAKE_CURRENT_BINARY_DIR`: diretório do `CMakeLists.txt` atual
- `CMAKE_CURRENT_LIST_DIR` / `CMAKE_CURRENT_LIST_FILE`: diretório e caminho do arquivo `.cmake` sendo executado
- `CMAKE_CURRENT_LIST_LINE`: linha atual (útil em mensagens)

---

**Projeto**

- `PROJECT_NAME`: nome passado ao `project()`
- `PROJECT_VERSION`, `PROJECT_VERSION_MAJOR`, `PROJECT_VERSION_MINOR`, `PROJECT_VERSION_PATCH`
- `PROJECT_DESCRIPTION`, `PROJECT_HOMEPAGE_URL`
- `PROJECT_IS_TOP_LEVEL` (3.21+): verdadeiro se é o projeto principal, e não uma dependência
- `CMAKE_VERSION`: versão do CMake em uso

---

**Compilador**

- `CMAKE_C_COMPILER`: caminho do compilador. Só pode ser definido na primeira configuração
- `CMAKE_C_COMPILER_ID`: `GNU`, `Clang`, `AppleClang`, `MSVC`, `IntelLLVM`...
- `CMAKE_C_COMPILER_VERSION`: ex: `14.2.0`
- `CMAKE_C_STANDARD`: padrão de C para todos os targets (`99`, `11`, `17`, `23`)
- `CMAKE_C_STANDARD_REQUIRED`: `ON` faz o configure falhar se o compilador não suportar o padrão
- `CMAKE_C_EXTENSIONS`: `ON` (padrão) usa `-std=gnu17`, `OFF` usa `-std=c17`
- `CMAKE_C_FLAGS`, `CMAKE_C_FLAGS_DEBUG`, `CMAKE_C_FLAGS_RELEASE`: flags globais (ver `build-types.md`)
- `CMAKE_EXE_LINKER_FLAGS`, `CMAKE_SHARED_LINKER_FLAGS`: flags globais de link

---

**Build**

- `CMAKE_BUILD_TYPE`: `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel` (single-config)
- `CMAKE_CONFIGURATION_TYPES`: configurações disponíveis (multi-config)
- `BUILD_SHARED_LIBS`: tipo padrão do `add_library` sem tipo (ver `libraries.md`)
- `CMAKE_EXPORT_COMPILE_COMMANDS`: gera `compile_commands.json` para o LSP (ver `debugging.md`)
- `CMAKE_POSITION_INDEPENDENT_CODE`: `-fPIC` em todos os targets
- `CMAKE_INTERPROCEDURAL_OPTIMIZATION`: liga LTO em todos os targets
- `CMAKE_COMPILE_WARNING_AS_ERROR` (3.24+): `-Werror` em todos os targets
- `CMAKE_COLOR_DIAGNOSTICS` (3.24+): mensagens coloridas do compilador, mesmo com Ninja
- `CMAKE_VERBOSE_MAKEFILE`: mostra os comandos completos durante o build

---

**Saída**

- `CMAKE_RUNTIME_OUTPUT_DIRECTORY`: onde ficam os executáveis (e `.dll`)
- `CMAKE_LIBRARY_OUTPUT_DIRECTORY`: onde ficam as `.so`/`.dylib`
- `CMAKE_ARCHIVE_OUTPUT_DIRECTORY`: onde ficam as `.a`

```cmake
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
```

- Sem elas, cada binário fica no diretório de build correspondente ao seu `CMakeLists.txt` (`build/app/app`, `build/src/libfila.a`)

---

**Plataforma**

- `WIN32`, `APPLE`, `UNIX`, `LINUX` (3.25+), `MSVC`: verdadeiras na plataforma ou compilador correspondente. `UNIX` é verdadeira também no macOS
- `CMAKE_SYSTEM_NAME`: sistema alvo (`Linux`, `Darwin`, `Windows`)
- `CMAKE_HOST_SYSTEM_NAME`: sistema onde o CMake está rodando (difere do alvo em cross-compiling)
- `CMAKE_SYSTEM_PROCESSOR`: arquitetura alvo (`x86_64`, `aarch64`, `arm64`)
- `CMAKE_SIZEOF_VOID_P`: `8` em 64 bits, `4` em 32 bits
- `CMAKE_OSX_ARCHITECTURES`: arquiteturas no macOS (`arm64`, `x86_64` ou as duas)
- `CMAKE_OSX_DEPLOYMENT_TARGET`: versão mínima do macOS suportada
- `CMAKE_CROSSCOMPILING`: verdadeira com um toolchain de outra plataforma (ver `toolchains.md`)

---

**Busca e instalação**

- `CMAKE_PREFIX_PATH`: prefixos onde o `find_package` e os `find_*` procuram (ver `dependencies.md`)
- `CMAKE_MODULE_PATH`: diretórios com `.cmake` usados por `include` e `find_package` em modo module
- `CMAKE_INSTALL_PREFIX`: destino do `cmake --install` (ver `install.md`)
- `CMAKE_TOOLCHAIN_FILE`: arquivo de toolchain (ver `toolchains.md`)
- `CMAKE_INSTALL_RPATH`: rpath gravado nos binários instalados (ver `libraries.md`)

> Muitas variáveis `CMAKE_X` são só o valor inicial de uma propriedade `X` de cada target. `CMAKE_C_STANDARD` preenche a propriedade `C_STANDARD` dos targets criados **depois** dela, e não muda os que já existem. Por isso essas variáveis devem ser definidas logo depois do `project()` (ver `properties.md`)
