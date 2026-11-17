**add_library**

> comando nativo do CMake, não precisa de include

O `add_library` cria um target de biblioteca a partir de uma lista de arquivos `.c`, e o tipo escolhido decide se o código é copiado para dentro do executável (estática) ou fica em um arquivo separado carregado ao executar (dinâmica)

```cmake
add_library(<nome> [STATIC|SHARED|MODULE|OBJECT] [EXCLUDE_FROM_ALL] <fonte>...)
add_library(<nome> INTERFACE)
add_library(<nome> <tipo> IMPORTED)
add_library(<novo nome> ALIAS <target>)
```

- `nome`: o nome do target. O arquivo gerado recebe o prefixo `lib` e a extensão automaticamente
- `STATIC`: biblioteca estática, `libnome.a`
- `SHARED`: biblioteca dinâmica, `libnome.so` no Linux e `libnome.dylib` no macOS
- `MODULE`: plugin carregado com `dlopen`. Não pode ser usado no `target_link_libraries`
- `OBJECT`: só compila os `.o`, que entram direto em cada target que a linka
- `INTERFACE`: não compila nada. Só carrega includes, macros e flags para quem a linka
- `IMPORTED`: representa uma biblioteca que já existe pronta, fora do projeto
- `ALIAS`: um segundo nome para um target existente, como `lista::lista`
- sem tipo: a variável `BUILD_SHARED_LIBS` decide, e o padrão é `STATIC`

- O `add_library` **cria** uma biblioteca a partir dos seus `.c`. Para usar uma biblioteca que já está instalada, use `find_package` ou `find_library`
- O CMake adiciona sozinho as flags de cada tipo: `ar` para a estática, `-fPIC` e `-shared` (ou `-dynamiclib`) para a dinâmica
- Uma `SHARED` roda direto do diretório de build porque o CMake grava o caminho dela no executável (`rpath`). Copiar só o executável para outro lugar faz ele não achar mais a biblioteca

```cmake
add_library(lista STATIC src/lista.c)
target_include_directories(lista PUBLIC include)

add_executable(app src/main.c)
target_link_libraries(app PRIVATE lista)
```

```text
gcc -Iinclude -c src/lista.c -o lista.o
ar rcs liblista.a lista.o
gcc -Iinclude -c src/main.c -o main.o
gcc main.o liblista.a -o app
```

---

**INTERFACE: um grupo de flags**

```cmake
add_library(avisos INTERFACE)
target_compile_options(avisos INTERFACE -Wall -Wextra -Wpedantic)

target_link_libraries(app PRIVATE avisos)
target_link_libraries(lista PRIVATE avisos)
```

- Uma `INTERFACE` não gera arquivo nenhum. Linkar a `avisos` só entrega as flags dela para o target
- Também serve para bibliotecas `header-only`, que só têm `.h` com funções `static inline` e macros

> Na dúvida entre `STATIC` e `SHARED`, use `STATIC`: o executável fica com tudo dentro e não depende de encontrar arquivos ao rodar. Use `SHARED` quando vários programas compartilham a mesma biblioteca ou ela precisa ser atualizada sem recompilar quem a usa
