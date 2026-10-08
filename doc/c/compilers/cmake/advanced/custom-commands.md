**Comandos personalizados**

> `configure_file`, `add_custom_command`, `add_custom_target` e `execute_process`

Nem tudo no build é compilar `.c`. Às vezes é preciso gerar um header com a versão do projeto, rodar uma ferramenta que produz código, copiar arquivos de dados para perto do executável ou executar algo depois do link. O CMake tem um comando para cada momento em que isso pode acontecer: no configure ou no build

```text
configure   configure_file      gera um arquivo substituindo variáveis
            execute_process     roda um programa agora e captura a saída
build       add_custom_command  gera um arquivo quando alguém precisar dele
            add_custom_target   um target que só roda comandos
```

---

**`configure_file`**

```c
// include/versao.h.in
#pragma once
#define VERSAO "@PROJECT_VERSION@"
#define VERSAO_MAJOR @PROJECT_VERSION_MAJOR@
#cmakedefine USAR_LOG
#cmakedefine01 TEM_STRLCPY
```

```cmake
configure_file(include/versao.h.in ${PROJECT_BINARY_DIR}/include/versao.h @ONLY)
target_include_directories(app PRIVATE ${PROJECT_BINARY_DIR}/include)
```

```c
// build/include/versao.h (gerado com USAR_LOG=ON e TEM_STRLCPY vazio)
#pragma once
#define VERSAO "1.2.0"
#define VERSAO_MAJOR 1
#define USAR_LOG
#define TEM_STRLCPY 0
```

- `@VAR@` é trocado pelo valor da variável. Sem `@ONLY`, `${VAR}` também é trocado
- `#cmakedefine VAR` vira `#define VAR` se a variável for verdadeira, ou `/* #undef VAR */` se for falsa
- `#cmakedefine01 VAR` vira `#define VAR 1` ou `#define VAR 0`
- O arquivo só é reescrito se o conteúdo mudar, então não força recompilação à toa
- Gere no diretório de **build**, nunca no código: o arquivo gerado depende da configuração

---

**`add_custom_command` (gerar arquivo)**

```cmake
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tabela.c
    COMMAND gerador_tabela ${CMAKE_CURRENT_SOURCE_DIR}/dados.csv ${CMAKE_CURRENT_BINARY_DIR}/tabela.c
    DEPENDS gerador_tabela dados.csv
    COMMENT "Gerando tabela.c"
    VERBATIM
)
add_executable(app main.c ${CMAKE_CURRENT_BINARY_DIR}/tabela.c)
```

- O comando só roda se algum target **usar** o `OUTPUT` (aqui, como fonte do `app`). Sem isso, nunca é executado
- Roda de novo quando algum `DEPENDS` muda. Se `DEPENDS` tiver um target (`gerador_tabela`), ele é compilado antes
- No `COMMAND`, o nome de um target executável é trocado pelo caminho completo
- `VERBATIM` faz o CMake escapar os argumentos corretamente para o shell da plataforma. Use sempre
- `BYPRODUCTS` declara arquivos extras que o comando também gera (necessário para o Ninja)

---

**`add_custom_command` (depois do build)**

```cmake
add_custom_command(TARGET app POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_CURRENT_SOURCE_DIR}/assets $<TARGET_FILE_DIR:app>/assets
    COMMENT "Copiando assets"
    VERBATIM
)
```

- `PRE_BUILD`, `PRE_LINK` e `POST_BUILD` rodam comandos em momentos do build de um target
- `POST_BUILD` roda toda vez que o target é linkado de novo
- `${CMAKE_COMMAND} -E` usa o próprio CMake como ferramenta portátil (ver `commands.md`)

---

**`add_custom_target`**

```cmake
add_custom_target(formatar
    COMMAND clang-format -i ${FONTES}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    COMMENT "Formatando o código"
    VERBATIM
)

add_custom_target(rodar
    COMMAND app
    DEPENDS app
    USES_TERMINAL
)
```

```bash
cmake --build build --target formatar
cmake --build build --target rodar
```

- Um target sem arquivo de saída: roda os comandos **toda vez** que é pedido
- Por padrão não faz parte do `all`. Com a opção `ALL`, roda em todo build
- `add_dependencies(app formatar)` faz um target esperar o outro
- `USES_TERMINAL` dá ao comando acesso direto ao terminal (útil com Ninja, que esconde a saída)

---

**`execute_process`**

```cmake
execute_process(
    COMMAND git rev-parse --short HEAD
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE resultado
    ERROR_QUIET
)
if(NOT resultado EQUAL 0)
    set(GIT_HASH "desconhecido")
endif()
```

- Roda **no configure**, uma vez. O valor não é atualizado a cada build, só quando o configure roda de novo
- `COMMAND_ERROR_IS_FATAL ANY` (3.19+) interrompe o configure se o comando falhar

---

**file**

```cmake
file(WRITE ${CMAKE_BINARY_DIR}/info.txt "versão ${PROJECT_VERSION}\n")
file(APPEND ${CMAKE_BINARY_DIR}/info.txt "compilador ${CMAKE_C_COMPILER_ID}\n")
file(READ arquivo.txt CONTEUDO)
file(STRINGS lista.txt LINHAS)                 # uma linha por elemento
file(COPY dados/ DESTINATION ${CMAKE_BINARY_DIR}/dados)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/saida)
file(DOWNLOAD https://example.com/a.txt ${CMAKE_BINARY_DIR}/a.txt EXPECTED_HASH SHA256=...)
file(GENERATE OUTPUT caminho CONTENT "...")    # no generate, com generator expressions
```

- Todos rodam no configure, menos `file(GENERATE)`
- `file(COPY)` copia uma vez no configure. Para manter os arquivos sempre atualizados, use `add_custom_command` com `POST_BUILD` ou `configure_file(... COPYONLY)`

> A pergunta para escolher o comando é **quando** o arquivo precisa ser atualizado. Se depende só de variáveis do CMake, `configure_file`. Se depende de outros arquivos que mudam durante o desenvolvimento, `add_custom_command` com `OUTPUT` e `DEPENDS`, para que o build o regenere sozinho
