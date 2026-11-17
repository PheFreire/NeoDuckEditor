**set**

> comando nativo do CMake, não precisa de include

O `set` cria ou muda uma variável do CMake, podendo também gravar o valor no cache para que ele continue valendo nas próximas configurações e possa ser mudado pelo terminal com `-D`

```cmake
set(<variável> <valor>... [PARENT_SCOPE])
set(<variável> <valor> CACHE <tipo> "<descrição>" [FORCE])
set(ENV{<variável>} <valor>)
unset(<variável>)
```

- `variável`: o nome. Diferencia maiúsculas de minúsculas
- `valor`: um ou mais valores. Vários valores viram uma lista (`a;b;c`)
- `PARENT_SCOPE`: grava a variável no escopo de quem chamou a função ou o `add_subdirectory`
- `CACHE tipo`: grava no cache. O tipo é `BOOL`, `STRING`, `PATH` ou `FILEPATH`, e a descrição aparece no `cmake -LH`
- `FORCE`: sobrescreve o valor que já está no cache. Sem ele, o `set(... CACHE ...)` só grava quando a variável ainda não existe
- `ENV{variável}`: muda uma variável de ambiente, só durante o configure

- A variável é lida com `${variável}`. Uma variável que não existe vira uma string vazia, sem erro
- Variáveis começadas com `CMAKE_` configuram o próprio CMake (tabela abaixo)
- Cada `add_subdirectory` e cada `function` tem escopo próprio: recebe uma cópia das variáveis, e o que muda lá dentro não volta

```cmake
set(FONTES main.c lista.c)                         # FONTES = "main.c;lista.c"
add_executable(app ${FONTES})

set(APP_PORTA 8080 CACHE STRING "Porta padrão")    # muda com -DAPP_PORTA=9000
target_compile_definitions(app PRIVATE PORTA=${APP_PORTA})
```

---

**Variáveis do CMake mais usadas**

| Variável | O que faz |
|---|---|
| `CMAKE_C_STANDARD` | padrão de C de todos os targets (`99`, `11`, `17`, `23`) |
| `CMAKE_C_STANDARD_REQUIRED` | `ON` faz o configure falhar se o compilador não suportar o padrão |
| `CMAKE_C_EXTENSIONS` | `OFF` usa `-std=c17` no lugar de `-std=gnu17` |
| `CMAKE_BUILD_TYPE` | `Debug`, `Release`, `RelWithDebInfo` ou `MinSizeRel` |
| `CMAKE_EXPORT_COMPILE_COMMANDS` | `ON` gera o `compile_commands.json` para o `clangd` |
| `CMAKE_RUNTIME_OUTPUT_DIRECTORY` | diretório onde todos os executáveis são gerados |
| `BUILD_SHARED_LIBS` | `ON` faz o `add_library` sem tipo gerar bibliotecas `SHARED` |
| `CMAKE_C_COMPILER` | o compilador. Só funciona pelo terminal, na primeira configuração |
| `PROJECT_SOURCE_DIR` | a raiz do projeto (só leitura) |
| `CMAKE_CURRENT_SOURCE_DIR` | o diretório do `CMakeLists.txt` que está rodando (só leitura) |

- As variáveis que configuram targets (`CMAKE_C_STANDARD`, `CMAKE_RUNTIME_OUTPUT_DIRECTORY`) só valem para os targets criados **depois** do `set`

> Uma variável do CMake não existe no código C. Para levar o valor ao programa, passe com `target_compile_definitions`, como no `PORTA=${APP_PORTA}` do exemplo (ver `functions/configuracao/target_compile_definitions.md`)
