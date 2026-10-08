**CPack**

> gerar pacotes .tar.gz, .zip, .deb, .rpm e .dmg

O CPack é a ferramenta de empacotamento que vem com o CMake. Ele usa as regras de `install` do projeto: instala tudo em um diretório temporário e transforma o resultado em um pacote no formato pedido. Se o `cmake --install` funciona, o CPack funciona

```cmake
# no final do CMakeLists.txt raiz, depois de todos os install()
set(CPACK_PACKAGE_VENDOR "Fila Projeto")
set(CPACK_PACKAGE_CONTACT "contato@example.com")
set(CPACK_GENERATOR "TGZ;DEB")
include(CPack)
```

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
cpack --config build/CPackConfig.cmake           # gera os pacotes no diretório atual
cmake --build build --target package             # o mesmo, pelo build
```

```text
fila-1.2.0-Linux.tar.gz
fila_1.2.0_amd64.deb
```

- `include(CPack)` deve vir **depois** de definir as variáveis `CPACK_*`, porque é ele que as grava em `CPackConfig.cmake`
- Nome, versão e descrição vêm do `project()` (`PROJECT_NAME`, `PROJECT_VERSION`, `PROJECT_DESCRIPTION`)

---

**Generators**

| Generator | Pacote | Plataforma |
|---|---|---|
| `TGZ`, `TXZ`, `ZIP` | arquivo compactado | todas |
| `DEB` | `.deb` (Debian, Ubuntu) | Linux, precisa do `dpkg` para algumas opções |
| `RPM` | `.rpm` (Fedora, openSUSE) | Linux, precisa do `rpmbuild` |
| `DragNDrop` | `.dmg` | macOS |
| `productbuild` | `.pkg` | macOS |
| `NSIS`, `WIX` | instalador `.exe`/`.msi` | Windows |

```bash
cpack -G ZIP --config build/CPackConfig.cmake     # escolhe o generator na hora
cpack -G DEB -C Release --config build/CPackConfig.cmake
```

---

**Variáveis comuns**

```cmake
set(CPACK_PACKAGE_NAME "fila")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Fila genérica em C")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Fila")
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")        # prefixo dentro do pacote
set(CPACK_STRIP_FILES ON)                         # remove símbolos de debug
```

- `CPACK_PACKAGING_INSTALL_PREFIX` é o prefixo usado dentro do pacote, que pode ser diferente do `CMAKE_INSTALL_PREFIX` usado no `cmake --install`

---

**Debian**

```cmake
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Mantenedor <contato@example.com>")
set(CPACK_DEBIAN_PACKAGE_SECTION "libs")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)            # detecta dependências com dpkg-shlibdeps
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)           # nome no padrão nome_versão_arquitetura.deb
```

```bash
dpkg -c fila_1.2.0_amd64.deb      # lista o conteúdo
dpkg -I fila_1.2.0_amd64.deb      # mostra as informações do pacote
```

- `SHLIBDEPS` analisa os binários e preenche o campo `Depends` com as bibliotecas compartilhadas usadas (como a `libc6`)

---

**Componentes**

```cmake
install(TARGETS app COMPONENT runtime)
install(TARGETS fila COMPONENT dev)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT dev)

set(CPACK_DEB_COMPONENT_INSTALL ON)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_COMPONENTS_ALL runtime dev)
include(CPack)
```

```text
fila-1.2.0-Linux-runtime.tar.gz
fila-1.2.0-Linux-dev.tar.gz
```

- Gera um pacote por componente, como as distros fazem com `fila` e `fila-dev`
- Os componentes vêm das regras de `install` (ver `install.md`)

---

**Pacote de código**

```cmake
set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_SOURCE_IGNORE_FILES "/build.*/;/\\.git/;\\.swp$")
include(CPack)
```

```bash
cmake --build build --target package_source       # fila-1.2.0-Source.tar.gz
```

- Empacota o código-fonte, não os binários. `CPACK_SOURCE_IGNORE_FILES` recebe regexes de caminhos a excluir

> O pacote gerado reflete exatamente as regras de `install`. Antes de investigar o CPack, rode `cmake --install build --prefix /tmp/teste` e confira se a árvore em `/tmp/teste` está como deveria. Um rpath errado ou um header faltando aparece ali primeiro
