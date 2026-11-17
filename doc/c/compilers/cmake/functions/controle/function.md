**function**

> comando nativo do CMake, não precisa de include

O `function` cria um comando novo a partir de um bloco de comandos, sendo usado para agrupar configurações repetidas, como os warnings e as bibliotecas que todo executável do projeto recebe

```cmake
function(<nome> [<parâmetro>...])
    ...
endfunction()
```

- `nome`: o nome do comando criado, chamado depois como `nome(argumentos)`
- `parâmetro`: os nomes dos argumentos. Dentro da função, cada um é uma variável

- Argumentos extras, além dos parâmetros declarados, ficam em `ARGN`. Todos estão em `ARGV`, e a quantidade em `ARGC`
- A função tem escopo próprio: variáveis criadas dentro dela não existem fora
- Uma função não devolve valor. Para devolver, ela grava em uma variável de quem chamou com `set(... PARENT_SCOPE)`
- O `macro()` tem a mesma forma, mas roda no escopo de quem chamou. Prefira `function`

```cmake
function(criar_app nome)
    add_executable(${nome} ${ARGN})                 # ARGN = os fontes passados
    target_link_libraries(${nome} PRIVATE lista avisos)
endfunction()

criar_app(servidor src/servidor.c)
criar_app(cliente src/cliente.c src/terminal.c)
```

```cmake
function(versao_completa saida)
    set(${saida} "${PROJECT_VERSION}-${CMAKE_BUILD_TYPE}" PARENT_SCOPE)
endfunction()

versao_completa(VERSAO)
message(STATUS "${VERSAO}")                         # -- 1.0.0-Debug
```

> Funções compartilhadas entre vários `CMakeLists.txt` ficam em um arquivo `.cmake` no diretório `cmake/`, carregado com `include` (ver `functions/projeto/include.md`)
