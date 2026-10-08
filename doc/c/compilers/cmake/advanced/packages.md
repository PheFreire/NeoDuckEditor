**Pacotes**

> exportar uma biblioteca para ser usada com `find_package`

Para que outros projetos usem a sua biblioteca com `find_package(Fila)` e `target_link_libraries(app PRIVATE Fila::fila)`, a instalação precisa incluir, além da `.a`/`.so` e dos headers, arquivos `.cmake` que recriam os targets na máquina de quem usa. O CMake gera esses arquivos a partir dos próprios targets do projeto

```text
prefixo/
├── include/fila/fila.h
├── lib/libfila.a
└── lib/cmake/Fila/
    ├── FilaConfig.cmake            ponto de entrada do find_package
    ├── FilaConfigVersion.cmake     compatibilidade de versão
    ├── FilaTargets.cmake           cria o target importado Fila::fila
    └── FilaTargets-release.cmake   caminho do arquivo em cada configuração
```

---

**Target preparado para exportar**

```cmake
cmake_minimum_required(VERSION 3.20)
project(Fila VERSION 1.2.0 LANGUAGES C)
include(GNUInstallDirs)

add_library(fila src/fila.c)
add_library(Fila::fila ALIAS fila)

target_include_directories(fila PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_features(fila PUBLIC c_std_11)
```

- Caminhos absolutos do código não podem ir para o pacote. `BUILD_INTERFACE` e `INSTALL_INTERFACE` separam os dois casos (ver `generator-expressions.md`)
- O alias `Fila::fila` faz com que o nome seja o mesmo tanto via `add_subdirectory`/`FetchContent` quanto via `find_package`

---

**Instalar e exportar**

```cmake
install(TARGETS fila
    EXPORT FilaTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT FilaTargets
    FILE FilaTargets.cmake
    NAMESPACE Fila::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Fila
)
```

- `EXPORT FilaTargets` registra o target em um conjunto de exportação
- `install(EXPORT)` gera `FilaTargets.cmake` com um `add_library(Fila::fila IMPORTED)` e todas as propriedades `INTERFACE_*`
- `NAMESPACE Fila::` é o prefixo que o target recebe no pacote

---

**Config e versão**

```cmake
# cmake/FilaConfig.cmake.in
@PACKAGE_INIT@

include(CMakeFindDependencyMacro)
find_dependency(Threads)

include("${CMAKE_CURRENT_LIST_DIR}/FilaTargets.cmake")
check_required_components(Fila)
```

```cmake
include(CMakePackageConfigHelpers)

configure_package_config_file(
    cmake/FilaConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/FilaConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Fila
)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/FilaConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/FilaConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/FilaConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Fila
)
```

- `@PACKAGE_INIT@` é trocado por código que calcula o prefixo de instalação a partir do próprio arquivo, então o pacote funciona mesmo se for movido
- `find_dependency` repassa as dependências `PUBLIC` da biblioteca: se `fila` linka `Threads::Threads` como `PUBLIC`, quem usa a fila também precisa encontrar `Threads`
- `COMPATIBILITY`: `SameMajorVersion` (1.x aceita pedidos de 1.0 a 1.x), `SameMinorVersion`, `ExactVersion` ou `AnyNewerVersion`

---

**Usando o pacote**

```bash
cmake -S fila -B fila/build -DCMAKE_BUILD_TYPE=Release
cmake --build fila/build
cmake --install fila/build --prefix ~/.local/fila

cmake -S app -B app/build -DCMAKE_PREFIX_PATH=~/.local/fila
```

```cmake
find_package(Fila 1.0 REQUIRED)
target_link_libraries(app PRIVATE Fila::fila)
```

---

**Exportar do diretório de build**

```cmake
export(EXPORT FilaTargets
    FILE ${CMAKE_CURRENT_BINARY_DIR}/FilaTargets.cmake
    NAMESPACE Fila::
)
```

- Permite que outro projeto use a biblioteca direto do diretório de build, sem instalar: `-DFila_DIR=/caminho/fila/build`
- Útil durante o desenvolvimento de dois projetos ao mesmo tempo

---

**Arquivo .pc para pkg-config**

```text
# cmake/fila.pc.in
prefix=@CMAKE_INSTALL_PREFIX@
libdir=${prefix}/@CMAKE_INSTALL_LIBDIR@
includedir=${prefix}/@CMAKE_INSTALL_INCLUDEDIR@

Name: fila
Description: Fila genérica em C
Version: @PROJECT_VERSION@
Libs: -L${libdir} -lfila
Cflags: -I${includedir}
```

```cmake
configure_file(cmake/fila.pc.in ${CMAKE_CURRENT_BINARY_DIR}/fila.pc @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/fila.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
```

- Permite que projetos que não usam CMake (Makefile, Meson) encontrem a biblioteca com `pkg-config --cflags --libs fila`

> Teste o pacote como um usuário faria: instale em um prefixo temporário e configure um projeto mínimo que só tem `find_package(Fila REQUIRED)` e um `target_link_libraries`. Um caminho absoluto esquecido em `target_include_directories` sem `BUILD_INTERFACE` faz o CMake dar erro na hora do `install(EXPORT)`, o que é melhor que descobrir na máquina de outra pessoa
