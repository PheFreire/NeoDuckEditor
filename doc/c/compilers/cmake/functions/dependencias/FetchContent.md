**FetchContent**

> módulo `FetchContent`, precisa de `include(FetchContent)`

O `FetchContent` baixa o código de uma dependência durante o configure e a adiciona ao projeto como se fosse um subdiretório, deixando os targets dela disponíveis para o `target_link_libraries`

```cmake
include(FetchContent)

FetchContent_Declare(<nome>
    GIT_REPOSITORY <url>
    GIT_TAG <tag ou commit>
)
FetchContent_Declare(<nome> URL <url do .tar.gz> [URL_HASH SHA256=<hash>])

FetchContent_MakeAvailable(<nome>...)
```

- `nome`: um nome para a dependência, usado no `FetchContent_MakeAvailable`
- `GIT_REPOSITORY` / `GIT_TAG`: o repositório e a versão. Use uma tag ou um commit fixo, e nunca um branch, para o build ser sempre igual
- `URL` / `URL_HASH`: baixa um arquivo compactado. O hash garante que o conteúdo não mudou
- `FetchContent_MakeAvailable`: baixa, se ainda não baixou, e executa o `CMakeLists.txt` da dependência como um `add_subdirectory`

- A dependência precisa ter um `CMakeLists.txt` próprio
- O download fica em `build/_deps/` e só acontece na primeira configuração
- A dependência é compilada junto com o projeto, com o mesmo compilador e o mesmo build type
- `-DFETCHCONTENT_FULLY_DISCONNECTED=ON` configura sem acessar a rede, usando o que já foi baixado

```cmake
include(FetchContent)

FetchContent_Declare(fila
    GIT_REPOSITORY https://exemplo.com/fila.git
    GIT_TAG v1.2.0
)
FetchContent_MakeAvailable(fila)

add_executable(app main.c)
target_link_libraries(app PRIVATE fila)      # target criado pelo CMakeLists.txt da fila
```

> Antes de usar o `FetchContent`, confira se a dependência já está instalada no sistema. O `find_package` evita baixar e recompilar o código a cada diretório de build novo
