**target_compile_definitions**

> comando nativo do CMake, não precisa de include

O `target_compile_definitions` define macros do preprocessor para os fontes de um target, gerando as flags `-D` na compilação, como se cada uma fosse um `#define` no início de todos os `.c` do target

```cmake
target_compile_definitions(<target>
    <PRIVATE|PUBLIC|INTERFACE> <macro>[=<valor>]...
)
```

- `target`: o target que recebe as macros. Precisa ter sido criado antes
- `PRIVATE`, `PUBLIC`, `INTERFACE`: use `PUBLIC` quando a macro é usada em um header público, para quem inclui o header receber a mesma macro (ver `functions/configuracao/target_link_libraries.md`)
- `macro`: só o nome, como `DEBUG`, vira `-DDEBUG` e vale `1`
- `valor`: com `=`, como `VERSAO=2`. Para um texto do C, as aspas precisam ser escapadas: `"NOME=\"app\""`

- Escreva sem o `-D`. Um `-D` no começo do item é removido
- O valor pode vir de uma variável do CMake: `PORTA=${APP_PORTA}`
- Para uma macro só em um build type: `$<$<CONFIG:Debug>:MODO_DEBUG>`

```cmake
target_compile_definitions(app PRIVATE
    DEBUG                                # -DDEBUG
    VERSAO=${PROJECT_VERSION_MAJOR}      # -DVERSAO=1
    "NOME=\"${PROJECT_NAME}\""           # -DNOME="app"
    $<$<CONFIG:Debug>:MODO_DEBUG>        # -DMODO_DEBUG só no Debug
)
```

```c
#ifdef DEBUG
    printf("%s v%d\n", NOME, VERSAO);    // app v1
#endif
```

> O `Release`, o `RelWithDebInfo` e o `MinSizeRel` já adicionam `-DNDEBUG`, que desliga os `assert`. Não é preciso definir essa macro à mão
