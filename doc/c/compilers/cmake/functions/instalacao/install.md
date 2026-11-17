**install**

> comando nativo do CMake, não precisa de include

O `install` define o que é copiado para o sistema ao rodar `cmake --install`: executáveis, bibliotecas, headers e outros arquivos, cada um para o seu diretório dentro do prefixo de instalação

```cmake
install(TARGETS <target>...
    [RUNTIME DESTINATION <diretório>]
    [LIBRARY DESTINATION <diretório>]
    [ARCHIVE DESTINATION <diretório>]
)
install(FILES <arquivo>... DESTINATION <diretório>)
install(DIRECTORY <diretório>/ DESTINATION <diretório>)
```

- `TARGETS`: os targets a instalar
- `RUNTIME`: executáveis, por padrão em `bin`
- `LIBRARY`: bibliotecas `.so` e `.dylib`, por padrão em `lib`
- `ARCHIVE`: bibliotecas `.a`, por padrão em `lib`
- `FILES`: arquivos avulsos, como um header
- `DIRECTORY`: um diretório inteiro. Com `/` no final copia só o conteúdo, sem ele copia o diretório junto
- `DESTINATION`: relativo ao prefixo de instalação, que é `/usr/local` por padrão

- Desde o CMake 3.14, `install(TARGETS app)` sozinho já usa os diretórios padrão
- O `include(GNUInstallDirs)` cria `CMAKE_INSTALL_BINDIR`, `CMAKE_INSTALL_LIBDIR` e `CMAKE_INSTALL_INCLUDEDIR` com os diretórios certos de cada sistema
- Um executável que usa uma biblioteca `SHARED` instalada precisa saber onde ela está. Configure o caminho antes de criar os targets: `set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")` no Linux ou `"@loader_path/../lib"` no macOS

```cmake
include(GNUInstallDirs)

install(TARGETS app lista)
install(DIRECTORY src/lista/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
```

```bash
cmake --build build
cmake --install build --prefix ~/.local
# ~/.local/bin/app
# ~/.local/lib/liblista.a
# ~/.local/include/lista/lista.h
```
