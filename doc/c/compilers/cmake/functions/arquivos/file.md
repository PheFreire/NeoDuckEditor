**file**

> comando nativo do CMake, não precisa de include

O `file` lê, escreve, copia e lista arquivos durante o configure, sendo o `GLOB` a forma mais usada, para montar uma lista de fontes a partir de um padrão como `src/*.c`

```cmake
file(GLOB <variável> [CONFIGURE_DEPENDS] <padrão>...)
file(GLOB_RECURSE <variável> [CONFIGURE_DEPENDS] <padrão>...)
file(COPY <arquivo|diretório>... DESTINATION <diretório>)
file(MAKE_DIRECTORY <diretório>...)
file(READ <arquivo> <variável>)
file(WRITE <arquivo> "<conteúdo>")
```

- `GLOB`: grava na variável a lista de arquivos que casam com o padrão
- `GLOB_RECURSE`: o mesmo, procurando também nos subdiretórios
- `CONFIGURE_DEPENDS`: confere o padrão de novo a cada build, para achar arquivos novos
- `COPY`: copia arquivos ou diretórios, como dados que o programa lê ao rodar
- `MAKE_DIRECTORY`: cria diretórios, como o `mkdir -p`
- `READ` / `WRITE`: lê um arquivo para uma variável ou escreve um texto em um arquivo

- Tudo roda no configure, e não no build
- Sem `CONFIGURE_DEPENDS`, um `.c` novo encontrado pelo `GLOB` só entra no build quando alguém roda o `cmake -S . -B build` de novo
- Com `CONFIGURE_DEPENDS`, cada build confere os diretórios, o que deixa projetos grandes mais lentos

```cmake
file(GLOB FONTES CONFIGURE_DEPENDS src/*.c)
add_executable(app ${FONTES})

file(COPY dados/ DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/dados)
```

> A recomendação do CMake é listar os fontes à mão no `add_executable` e no `add_library`. O diff do `CMakeLists.txt` mostra quais arquivos entraram ou saíram do build, e um arquivo esquecido no diretório nunca é compilado por acidente
