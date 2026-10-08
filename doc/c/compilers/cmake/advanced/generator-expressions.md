**Generator expressions**

> expressões `$<...>` avaliadas no generate

Uma generator expression é um trecho `$<...>` que **não** é avaliado quando o `CMakeLists.txt` executa, e sim depois, na fase de generate, quando o CMake já sabe a configuração de cada build (Debug ou Release), o compilador e o caminho final de cada target. Isso resolve problemas que um `if` não consegue resolver, como em generators multi-config, onde o mesmo diretório tem Debug e Release ao mesmo tempo

```cmake
target_compile_definitions(app PRIVATE
    $<$<CONFIG:Debug>:MODO_DEBUG>
)
```

```text
configure:  COMPILE_DEFINITIONS = "$<$<CONFIG:Debug>:MODO_DEBUG>"   (texto cru)
generate:   Debug   → -DMODO_DEBUG
            Release → (nada)
```

> As fases estão em `build-process.md`

---

**Condicionais**

```cmake
$<condição:valor>                 # valor se condição for 1, vazio se for 0
$<IF:condição,se_sim,se_não>      # if/else
$<BOOL:${VAR}>                    # converte qualquer valor do CMake em 0 ou 1
$<NOT:condição>
$<AND:c1,c2>
$<OR:c1,c2>
$<STREQUAL:a,b>
$<EQUAL:1,1>
$<VERSION_GREATER_EQUAL:${CMAKE_C_COMPILER_VERSION},13>
```

- A `condição` precisa ser exatamente `0` ou `1`. Uma variável com `ON` precisa passar por `$<BOOL:...>`
- `$<$<CONFIG:Debug>:X>` é uma condição dentro de outra: a interna gera `0` ou `1`, a externa gera `X` ou nada

---

**Consultas**

```cmake
$<CONFIG>                         # nome da configuração: Debug, Release...
$<CONFIG:Debug,RelWithDebInfo>    # 1 se a configuração for uma delas
$<PLATFORM_ID:Linux,Darwin>       # sistema alvo
$<C_COMPILER_ID:GNU,Clang>        # compilador
$<C_COMPILER_VERSION:14.2.0>
$<COMPILE_LANGUAGE:C>             # 1 ao compilar arquivos C (útil com C e C++ juntos)
$<TARGET_EXISTS:fila>
```

```cmake
$<TARGET_FILE:app>                # caminho completo de build/app
$<TARGET_FILE_NAME:fila>          # libfila.so
$<TARGET_FILE_DIR:fila>           # diretório onde a lib foi gerada
$<TARGET_LINKER_FILE:fila>        # arquivo usado no link
$<TARGET_OBJECTS:comum>           # lista de .o de uma biblioteca OBJECT
$<TARGET_PROPERTY:fila,VERSION>   # valor de uma propriedade
```

- Os caminhos de `$<TARGET_FILE:...>` mudam conforme a configuração e o generator, por isso não existem no configure
- São muito usados em `add_custom_command` e `add_test` (ver `custom-commands.md`)

---

**`BUILD_INTERFACE` e `INSTALL_INTERFACE`**

```cmake
target_include_directories(fila PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
```

- `BUILD_INTERFACE`: vale enquanto o projeto é compilado do código
- `INSTALL_INTERFACE`: vale depois que a biblioteca é instalada e encontrada com `find_package`, relativo ao prefixo de instalação
- Necessário porque o caminho absoluto do código não existe na máquina de quem instala o pacote (ver `packages.md`)

---

**Outras transformações**

```cmake
$<LOWER_CASE:Texto>               # texto
$<UPPER_CASE:texto>               # TEXTO
$<JOIN:${LISTA},:>                # junta com ":"
$<REMOVE_DUPLICATES:${LISTA}>
$<FILTER:${LISTA},INCLUDE,\\.c$>  # filtra por regex
$<LIST:LENGTH,${LISTA}>           # operações de lista (3.27+)
$<COMMA>                          # uma vírgula literal
$<SEMICOLON>                      # um ponto e vírgula literal
$<ANGLE-R>                        # um > literal
$<LINK_ONLY:fila>                 # só linka, sem propagar includes e flags
```

---

**Espaços e listas**

```cmake
# errado: o espaço quebra a expressão em dois argumentos
target_compile_options(app PRIVATE $<$<CONFIG:Debug>:-g3 -Og>)

# certo: aspas e itens separados por ;
target_compile_options(app PRIVATE "$<$<CONFIG:Debug>:-g3;-Og>")

# certo: uma expressão por item
target_compile_options(app PRIVATE $<$<CONFIG:Debug>:-g3> $<$<CONFIG:Debug>:-Og>)
```

- Sem aspas, o CMake separa os argumentos pelos espaços antes de saber que existe uma expressão, e o resultado são duas expressões incompletas
- Expressões longas podem ser guardadas em variáveis para ficar legíveis: `set(eh_gcc "$<C_COMPILER_ID:GNU>")` e depois `$<${eh_gcc}:-fanalyzer>`

---

**Depurar**

```cmake
file(GENERATE OUTPUT ${CMAKE_BINARY_DIR}/debug-genex.txt
    CONTENT "config=$<CONFIG>\narquivo=$<TARGET_FILE:app>\ninc=$<TARGET_PROPERTY:app,INCLUDE_DIRECTORIES>\n"
)
```

```bash
cmake -S . -B build && cat build/debug-genex.txt
```

- `message` imprime o texto cru, porque roda no configure. `file(GENERATE)` escreve o resultado avaliado no generate
- Em generators multi-config, use `$<CONFIG>` no nome do arquivo para gerar um por configuração

> Generator expressions só funcionam onde a documentação do comando ou da propriedade diz que são aceitas (comandos `target_*`, `install`, `add_custom_command`, `add_test`, `file(GENERATE)`). Em `if`, `message`, `set` ou `string`, elas são só texto
