**Variáveis**

> variáveis normais, cache, ambiente, escopo e listas

Existem três tipos de variáveis no CMake. As **normais** existem só durante o configure e somem no fim. As de **cache** ficam gravadas em `CMakeCache.txt` e sobrevivem entre execuções, sendo o jeito de o usuário configurar o projeto com `-D`. As de **ambiente** são as do processo, lidas com `$ENV{...}`

```cmake
set(FONTES main.c lista.c)                           # normal
set(TAMANHO_BUFFER 1024 CACHE STRING "Tamanho do buffer")   # cache
option(USAR_LOG "Habilita log" OFF)                  # cache booleana
message("${FONTES} ${TAMANHO_BUFFER} $ENV{HOME}")
```

```bash
cmake -S . -B build -DTAMANHO_BUFFER=4096 -DUSAR_LOG=ON
```

---

**Variáveis normais**

```cmake
set(NOME valor)          # define
set(NOME a b c)          # define uma lista "a;b;c"
set(NOME "")             # string vazia (mas definida)
unset(NOME)              # remove
```

- O valor é sempre uma string. `set(X 10)` guarda o texto `10`
- `if(DEFINED NOME)` testa se existe, mesmo vazia (ver `control-flow.md`)

---

**Escopo**

```text
CMakeLists.txt (raiz)            ← escopo do diretório raiz
  │  add_subdirectory(src)
  ▼
src/CMakeLists.txt               ← escopo novo, começa com uma cópia do pai
  │  minha_funcao()
  ▼
function minha_funcao            ← escopo novo, começa com uma cópia de quem chamou
```

- `add_subdirectory` e `function` criam um escopo novo, que recebe uma **cópia** das variáveis do escopo de cima. Mudanças ficam no escopo novo e não voltam
- `macro` e `include` **não** criam escopo: rodam no escopo de quem chamou
- `set(X valor PARENT_SCOPE)` escreve no escopo de cima. É assim que funções devolvem resultados

```cmake
function(dobro valor saida)
    math(EXPR r "${valor} * 2")
    set(${saida} ${r} PARENT_SCOPE)
endfunction()

dobro(21 RESULTADO)
message("${RESULTADO}")   # 42
```

> `targets`, ao contrário das variáveis, são globais: um target criado em `src/CMakeLists.txt` pode ser usado em qualquer outro diretório (ver `subdirectories.md`)

---

**Cache**

```cmake
set(NOME valor CACHE TIPO "descrição")
set(NOME valor CACHE TIPO "descrição" FORCE)   # sobrescreve o valor existente
option(NOME "descrição" OFF)                   # o mesmo que um cache BOOL
```

| Tipo | Uso | Na interface (`ccmake`) |
|---|---|---|
| `BOOL` | `ON`/`OFF` | checkbox |
| `STRING` | texto livre | campo de texto |
| `PATH` | diretório | seletor de diretório |
| `FILEPATH` | arquivo | seletor de arquivo |
| `INTERNAL` | uso interno, oculto | não aparece |

- `set(... CACHE ...)` **não** muda um valor que já está no cache. O primeiro valor vence, e é isso que permite ao usuário sobrescrever com `-D`. Use `FORCE` só quando o projeto realmente precisa impor o valor
- Se existe uma variável normal e uma de cache com o mesmo nome, `${NOME}` retorna a **normal**. `$CACHE{NOME}` lê direto do cache
- Valores do cache aparecem com `cmake -LH build` e podem ser editados em `ccmake build` (ver `commands.md`)
- Para restringir os valores aceitos de uma `STRING`: `set_property(CACHE NOME PROPERTY STRINGS a b c)`

---

**Variáveis de ambiente**

```cmake
message("$ENV{PATH}")
if(DEFINED ENV{CI})
    message(STATUS "Rodando no CI")
endif()
set(ENV{MINHA_VAR} valor)   # vale só para o processo do cmake
```

- `set(ENV{...})` só afeta o configure atual. **Não** chega ao build nem aos testes. Para isso use propriedades como `ENVIRONMENT` do teste (ver `testing.md`)
- Algumas variáveis de ambiente são lidas pelo próprio CMake na primeira configuração: `CC`, `CFLAGS`, `LDFLAGS`, `CMAKE_BUILD_TYPE`, `CMAKE_GENERATOR`, `CMAKE_PREFIX_PATH`

---

**Listas**

Uma lista é uma string com elementos separados por `;`. `set(L a b c)` e `set(L "a;b;c")` produzem exatamente o mesmo valor

```cmake
set(L c a b)
list(APPEND L d)              # c;a;b;d
list(LENGTH L N)              # N = 4
list(GET L 0 PRIMEIRO)        # PRIMEIRO = c
list(SORT L)                  # a;b;c;d
list(REMOVE_ITEM L b)         # a;c;d
list(FIND L c POS)            # POS = 1 (ou -1 se não achar)
list(JOIN L ", " TEXTO)       # "a, c, d"
list(TRANSFORM L PREPEND src/)   # src/a;src/c;src/d
```

- Comandos que alteram a lista recebem o **nome** da variável (`L`), e não o valor (`${L}`)

---

**Strings e números**

```cmake
string(TOUPPER "${NOME}" NOME_UP)
string(REPLACE "-" "_" ID "${NOME}")
string(APPEND MSG " mais texto")
string(LENGTH "${NOME}" N)
string(REGEX MATCH "[0-9]+" NUM "versao 42")   # NUM = 42
string(STRIP "${TEXTO}" TEXTO)
math(EXPR TOTAL "4 * 8 + 1")                    # TOTAL = 33
cmake_path(GET ARQUIVO FILENAME NOME_ARQ)        # manipula caminhos (3.20+)
```

> Prefira `cmake_path` a `string` para manipular caminhos de arquivo: ele entende separadores, extensões e caminhos relativos (`cmake_path(GET p EXTENSION ext)`, `cmake_path(APPEND p "include")`, `cmake_path(RELATIVE_PATH p BASE_DIRECTORY dir)`)
