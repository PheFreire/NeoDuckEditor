**Controle de fluxo**

> if, foreach, while, function e macro

Como o `CMakeLists.txt` é executado como um script durante o configure, ele tem condicionais, laços e funções. Todos são comandos que abrem e fecham um bloco (`if` / `endif`, `foreach` / `endforeach`)

```cmake
if(USAR_LOG)
    target_compile_definitions(app PRIVATE USAR_LOG)
endif()

foreach(nome IN ITEMS fila pilha lista)
    add_library(${nome} STATIC src/${nome}.c)
endforeach()
```

---

**if**

```cmake
if(condição)
    ...
elseif(outra)
    ...
else()
    ...
endif()
```

- O `if` recebe os argumentos **sem** `${}` quando são nomes de variáveis: `if(USAR_LOG)` lê o valor da variável `USAR_LOG`
- Valores verdadeiros: `1`, `ON`, `YES`, `TRUE`, `Y` e qualquer número diferente de zero
- Valores falsos: `0`, `OFF`, `NO`, `FALSE`, `N`, `IGNORE`, `NOTFOUND`, string vazia e qualquer valor terminado em `-NOTFOUND`
- As constantes não diferenciam maiúsculas de minúsculas (`on` = `ON`)
- Qualquer outra string é tratada como nome de variável. `if(abc)` é verdadeiro só se existir uma variável `abc` com valor verdadeiro

---

**Condições**

```cmake
if(DEFINED NOME)                      # a variável existe
if(NOT USAR_LOG)                      # negação
if(A AND (B OR C))                    # lógica, com parênteses
if(NOME STREQUAL "app")               # comparação de strings
if(N EQUAL 3)                         # comparação numérica (LESS, GREATER, LESS_EQUAL...)
if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 13)   # versões (1.10 > 1.9)
if(NOME MATCHES "^lib(.*)$")          # regex, captura em CMAKE_MATCH_1
if("fila" IN_LIST TARGETS)            # elemento em uma lista
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/config.h")   # arquivo existe (caminho absoluto)
if(IS_DIRECTORY caminho)              # é diretório
if(TARGET fila)                       # já existe um target com esse nome
if(COMMAND minha_funcao)              # existe um comando ou função
```

- Plataforma: `if(WIN32)`, `if(APPLE)`, `if(UNIX)` (verdadeiro também no macOS), `if(LINUX)` (3.25+)
- Compilador: `if(CMAKE_C_COMPILER_ID STREQUAL "GNU")` (outros valores: `Clang`, `AppleClang`, `MSVC`)

> Cuidado com `if(CMAKE_BUILD_TYPE STREQUAL "Debug")`: em generators multi-config essa variável é vazia, porque a configuração só é escolhida no build. Use generator expressions como `$<CONFIG:Debug>` (ver `generator-expressions.md`)

---

**foreach**

```cmake
foreach(f IN ITEMS a.c b.c)            # itens literais
foreach(f IN LISTS FONTES EXTRAS)      # elementos de uma ou mais listas (nomes, sem ${})
foreach(i RANGE 3)                     # 0 1 2 3
foreach(i RANGE 1 10 2)                # 1 3 5 7 9
foreach(nome valor IN ZIP_LISTS NOMES VALORES)   # percorre duas listas juntas (3.17+)
    ...
endforeach()
```

- `break()` sai do laço, `continue()` pula para o próximo elemento

---

**while**

```cmake
set(i 0)
while(i LESS 5)
    math(EXPR i "${i} + 1")
endwhile()
```

- Raramente usado. Quase todo laço em CMake é um `foreach` sobre uma lista

---

**function**

```cmake
function(adicionar_exemplo nome)
    add_executable(${nome} exemplos/${nome}.c)
    target_link_libraries(${nome} PRIVATE fila)
endfunction()

adicionar_exemplo(basico)
adicionar_exemplo(avancado)
```

- Cria um escopo novo: variáveis definidas dentro não vazam (ver `variables.md`)
- Argumentos extras ficam em `ARGN`. Todos os argumentos em `ARGV`, a quantidade em `ARGC`
- Para devolver um valor: `set(${saida} valor PARENT_SCOPE)`
- `return()` sai da função (ou do arquivo, se usado fora de uma função)

---

**Argumentos nomeados**

```cmake
function(criar_lib nome)
    cmake_parse_arguments(PARSE_ARGV 1 arg "SHARED" "DESTINO" "FONTES;DEPS")
    # arg_SHARED (TRUE/FALSE), arg_DESTINO (um valor), arg_FONTES e arg_DEPS (listas)
    if(arg_SHARED)
        add_library(${nome} SHARED ${arg_FONTES})
    else()
        add_library(${nome} STATIC ${arg_FONTES})
    endif()
    target_link_libraries(${nome} PRIVATE ${arg_DEPS})
endfunction()

criar_lib(fila SHARED FONTES fila.c no.c DEPS m)
```

- Os três grupos são: opções sem valor, palavras com um valor e palavras com vários valores
- `PARSE_ARGV 1` começa a análise depois do primeiro argumento posicional (`nome`)
- Argumentos que não casaram com nenhuma palavra ficam em `arg_UNPARSED_ARGUMENTS`

---

**macro**

```cmake
macro(definir_padrao var valor)
    if(NOT DEFINED ${var})
        set(${var} ${valor})
    endif()
endmacro()
```

- Uma macro é substituição de texto: **não** cria escopo, então um `set` dentro dela altera o escopo de quem chamou
- Os parâmetros não são variáveis de verdade, e sim trechos substituídos. `if(DEFINED ARGV0)` não funciona como esperado dentro de uma macro
- `return()` dentro de uma macro sai de quem a chamou

> Prefira `function` a `macro`. A falta de escopo da macro causa bugs difíceis de encontrar quando uma variável interna sobrescreve uma variável de quem chamou. Use macro só quando a intenção é justamente alterar o escopo de quem chamou
