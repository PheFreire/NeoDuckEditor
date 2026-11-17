**add_executable**

> comando nativo do CMake, não precisa de include

O `add_executable` cria um target de executável a partir de uma lista de arquivos `.c`, que no build são compilados e linkados em um programa com o nome do target

```cmake
add_executable(<nome> [EXCLUDE_FROM_ALL] <fonte>...)
```

- `nome`: o nome do target, único em todo o projeto. Também vira o nome do arquivo gerado
- `fonte`: os `.c` que formam o executável, relativos ao diretório do `CMakeLists.txt`. Headers não precisam ser listados
- `EXCLUDE_FROM_ALL`: não compila no `cmake --build build`, só quando pedido com `-t nome`

- Cada executável precisa ter exatamente um `main` entre os seus fontes. Dois `main` no mesmo target dão erro de símbolo duplicado no link
- Um projeto pode ter quantos executáveis quiser, cada um com o seu `add_executable`
- O arquivo é gerado no diretório de build que espelha o `CMakeLists.txt` que o criou. O `CMAKE_RUNTIME_OUTPUT_DIRECTORY` junta todos em um diretório só
- O nome do arquivo muda sem mudar o do target com `set_target_properties(app PROPERTIES OUTPUT_NAME meu_app)`
- Fontes podem ser adicionadas depois com `target_sources`

```cmake
add_library(rede STATIC src/rede.c)          # código usado pelos dois executáveis

add_executable(servidor src/servidor.c)
add_executable(cliente src/cliente.c)
target_link_libraries(servidor PRIVATE rede)
target_link_libraries(cliente PRIVATE rede)
```

```bash
cmake --build build                  # compila os dois
cmake --build build -t cliente       # só o cliente e a rede, que ele usa
```

> Liste os fontes explicitamente. Com `file(GLOB)`, um `.c` novo só entra no build depois de rodar o configure de novo (ver `functions/arquivos/file.md`)
