**Instalação**

> install, GNUInstallDirs e cmake --install

Instalar é copiar os arquivos que interessam ao usuário (executáveis, bibliotecas, headers) do diretório de build para um `prefixo` com a estrutura padrão `bin/`, `lib/` e `include/`. O comando `install` só registra as regras durante o configure. A cópia acontece quando `cmake --install` é executado

```cmake
include(GNUInstallDirs)

install(TARGETS app fila)
install(FILES include/fila.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
```

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
cmake --install build --prefix ~/.local
```

```text
~/.local/
├── bin/app
├── include/fila.h
└── lib/libfila.a
```

---

**Prefixo**

```bash
cmake --install build                            # usa CMAKE_INSTALL_PREFIX
cmake --install build --prefix /opt/fila         # sobrescreve na hora
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/opt/fila
sudo cmake --install build                       # padrão /usr/local precisa de root
DESTDIR=/tmp/pacote cmake --install build        # instala em /tmp/pacote/usr/local/...
```

- O padrão de `CMAKE_INSTALL_PREFIX` é `/usr/local` no Linux e no macOS
- `DESTDIR` é adicionado na frente do prefixo. É usado para montar pacotes sem tocar no sistema
- `cmake --install` (3.15+) substitui o antigo `make install` e funciona com qualquer generator
- Generators multi-config precisam de `--config Release`

---

**GNUInstallDirs**

```cmake
include(GNUInstallDirs)
```

| Variável | Valor comum |
|---|---|
| `CMAKE_INSTALL_BINDIR` | `bin` |
| `CMAKE_INSTALL_LIBDIR` | `lib` ou `lib64` (depende da distro) |
| `CMAKE_INSTALL_INCLUDEDIR` | `include` |
| `CMAKE_INSTALL_DATADIR` | `share` |
| `CMAKE_INSTALL_MANDIR` | `share/man` |
| `CMAKE_INSTALL_DOCDIR` | `share/doc/PROJECT_NAME` |

- Os valores são relativos ao prefixo e seguem as convenções de cada sistema. Use essas variáveis em vez de escrever `lib` direto
- Existem também as versões absolutas: `CMAKE_INSTALL_FULL_LIBDIR`

---

**install(TARGETS)**

```cmake
install(TARGETS app fila
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}      # executáveis (e .dll no Windows)
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}      # .so / .dylib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}      # .a
)
```

- A partir do 3.14, sem `DESTINATION`, os valores do `GNUInstallDirs` são usados automaticamente
- Na instalação, o CMake reescreve o rpath dos binários (ver `libraries.md`)
- Para uma biblioteca que será usada com `find_package`, adicione `EXPORT` (ver `packages.md`)

---

**Headers**

```cmake
# arquivos específicos
install(FILES include/fila/fila.h include/fila/no.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/fila)

# um diretório inteiro
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# file set (3.23+): os headers fazem parte do target
target_sources(fila PUBLIC
    FILE_SET HEADERS
    BASE_DIRS include
    FILES include/fila/fila.h include/fila/no.h
)
install(TARGETS fila FILE_SET HEADERS)
```

- `install(DIRECTORY include/ ...)` com a barra no final copia o **conteúdo** de `include/`. Sem a barra, cria `include/include/`
- O `FILE_SET HEADERS` também adiciona o `BASE_DIRS` aos includes do target, sem precisar de `target_include_directories`

---

**Outros arquivos**

```cmake
install(PROGRAMS scripts/fila-config DESTINATION ${CMAKE_INSTALL_BINDIR})   # com permissão de execução
install(FILES doc/fila.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)
install(FILES LICENSE README.md DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(CODE "message(STATUS \"Instalação concluída\")")                   # código CMake na hora de instalar
```

---

**Componentes**

```cmake
install(TARGETS app COMPONENT runtime)
install(TARGETS fila COMPONENT dev)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT dev)
```

```bash
cmake --install build --component runtime     # só o executável
```

- Componentes dividem a instalação em partes. O CPack os usa para gerar pacotes separados, como `fila` e `fila-dev` (ver `cpack.md`)

> O CMake não tem um comando de desinstalar. A lista de tudo que foi copiado fica em `build/install_manifest.txt`, então `xargs rm < build/install_manifest.txt` remove os arquivos instalados. Para não precisar disso, instale em um prefixo próprio (`--prefix ~/.local/fila`) ou gere um pacote do sistema com o CPack
