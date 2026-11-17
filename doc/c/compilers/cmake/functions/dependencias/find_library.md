**find_library**

> comando nativo do CMake, não precisa de include

O `find_library` procura o arquivo de uma biblioteca já compilada (`.a`, `.so` ou `.dylib`) nos diretórios do sistema e grava o caminho completo dele em uma variável, para ser passado ao `target_link_libraries`

```cmake
find_library(<variável> NAMES <nome>... [PATHS <diretório>...] [REQUIRED])
find_library(<variável> <nome>)
```

- `variável`: recebe o caminho encontrado, ou `<variável>-NOTFOUND` quando não encontra
- `nome`: o nome sem o prefixo `lib` e sem a extensão. `fila` encontra `libfila.so`, `libfila.dylib` ou `libfila.a`
- `PATHS`: diretórios extras para procurar, além dos do sistema
- `REQUIRED` (3.18+): para o configure com erro se não encontrar

- O resultado fica gravado no cache, e as próximas configurações não procuram de novo. Para procurar de novo, use `--fresh` ou remova a variável com `-U FILA_LIB`
- Quando as duas versões existem no mesmo diretório, a dinâmica é escolhida. Para forçar a estática, passe o nome completo: `NAMES libfila.a`
- Só encontra o arquivo da biblioteca. O diretório do header vem do `find_path`

```cmake
find_library(FILA_LIB fila REQUIRED)
find_path(FILA_INCLUDE fila.h REQUIRED)

add_executable(app main.c)
target_link_libraries(app PRIVATE ${FILA_LIB})
target_include_directories(app PRIVATE ${FILA_INCLUDE})
```

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=/opt/fila    # procura também em /opt/fila/lib e /opt/fila/include
```

> Prefira o `find_package` quando a biblioteca oferece suporte a ele. Ele já entrega o header, o arquivo e as dependências da biblioteca em um único target
