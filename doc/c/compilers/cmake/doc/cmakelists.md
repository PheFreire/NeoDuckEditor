**CMakeLists.txt**

> a linguagem do CMake: comandos, argumentos e comentários

O `CMakeLists.txt` é um script em uma linguagem própria, executado de cima para baixo durante o configure. A linguagem só tem um tipo de instrução: a chamada de comando. Não existem operadores, `return` de valores ou tipos. Tudo é string, e listas são strings com elementos separados por `;`

```cmake
cmake_minimum_required(VERSION 3.20)
project(app VERSION 1.0.0 LANGUAGES C)

set(FONTES main.c lista.c)        # variável com uma lista de 2 elementos

add_executable(app ${FONTES})
target_include_directories(app PRIVATE include)
```

- Cada linha é `nome_do_comando(argumentos)`
- O nome do comando **não** diferencia maiúsculas de minúsculas (`add_executable` = `ADD_EXECUTABLE`). O padrão moderno é tudo minúsculo
- Nomes de variáveis **diferenciam** maiúsculas de minúsculas (`FONTES` e `fontes` são variáveis diferentes)
- Palavras-chave dentro dos argumentos (`PRIVATE`, `VERSION`, `LANGUAGES`) são escritas em maiúsculo

---

**Estrutura típica**

```cmake
cmake_minimum_required(VERSION 3.20)                 # 1. versão e policies
project(app VERSION 1.2.0 DESCRIPTION "Exemplo" LANGUAGES C)   # 2. projeto

option(USAR_LOG "Habilita mensagens de log" OFF)     # 3. opções do usuário

find_package(Threads REQUIRED)                       # 4. dependências

add_library(fila STATIC src/fila.c)                  # 5. targets
target_include_directories(fila PUBLIC include)

add_executable(app src/main.c)
target_link_libraries(app PRIVATE fila Threads::Threads)

if(USAR_LOG)                                         # 6. configuração condicional
    target_compile_definitions(app PRIVATE USAR_LOG)
endif()
```

- `project(... VERSION 1.2.0)` cria `PROJECT_VERSION`, `PROJECT_VERSION_MAJOR`, `PROJECT_VERSION_MINOR` e `PROJECT_VERSION_PATCH`
- `project()` é quem detecta o compilador. Comandos que dependem dele (como `add_executable`) devem vir depois

---

**Argumentos**

```cmake
message(a b c)              # 3 argumentos sem aspas, imprime "abc"
message("a b c")            # 1 argumento entre aspas, imprime "a b c"
message("valor: ${X}")      # variáveis são expandidas dentro de aspas
message([[sem ${X} aqui]])  # bracket argument: nada é expandido
```

- **Sem aspas**: os argumentos são separados por espaços, tabs ou quebras de linha. Uma variável sem aspas que contém uma lista vira **vários** argumentos
- **Com aspas**: o texto inteiro é um único argumento, mesmo com espaços ou `;`. Pode ter várias linhas
- **Bracket** (`[[ ... ]]` ou `[=[ ... ]=]`): o texto é usado literalmente, sem expandir variáveis nem tratar `\`

```cmake
set(L a b c)          # L = "a;b;c"
message(${L})         # vira message(a b c), imprime "abc"
message("${L}")       # um argumento, imprime "a;b;c"
```

> Na dúvida, coloque aspas em volta de variáveis que podem ter espaços (caminhos de arquivo, mensagens)

---

**Variáveis e referências**

```cmake
set(NOME "app")
message("${NOME}")              # variável normal
message("$ENV{HOME}")           # variável de ambiente
message("$CACHE{CMAKE_BUILD_TYPE}")   # lê direto do cache, ignorando a variável normal
message("${PREFIXO_${NOME}}")   # referências podem ser aninhadas
```

- Uma variável que não existe expande para uma string vazia, sem erro. `cmake --warn-uninitialized` avisa nesses casos (ver `debugging.md`)
- A sintaxe `${...}` é expandida antes do comando ser chamado. O comando recebe só o resultado
- Mais detalhes sobre escopo, cache e listas em `variables.md`

---

**Comentários**

```cmake
# comentário até o fim da linha

#[[
comentário de várias linhas
add_executable(antigo antigo.c)
]]
```

- `#[[ ... ]]` é útil para desativar um bloco inteiro de código

---

**Mensagens**

```cmake
message("texto")                    # aviso simples (stderr)
message(STATUS "Versão: ${PROJECT_VERSION}")   # linha com "-- " (stdout)
message(WARNING "Opção obsoleta")   # aviso com o arquivo e a linha
message(FATAL_ERROR "Falta X")      # para o configure imediatamente
```

- `STATUS` é o modo usado para informar o que o configure encontrou
- `FATAL_ERROR` interrompe o configure e nenhum arquivo de build é gerado
- Todos os modos estão em `debugging.md`

> A linguagem do CMake não tem `return` com valor. Funções devolvem resultados escrevendo em uma variável do escopo de quem chamou, e é por isso que tantos comandos recebem o nome de uma variável de saída como argumento, como `list(LENGTH lista TAMANHO)` ou `find_library(M_LIB m)` (ver `control-flow.md`)
