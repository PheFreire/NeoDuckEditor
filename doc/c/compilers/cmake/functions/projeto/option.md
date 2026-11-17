**option**

> comando nativo do CMake, não precisa de include

O `option` cria uma opção liga e desliga que quem compila pode mudar pelo terminal com `-D`, sem editar o `CMakeLists.txt`

```cmake
option(<nome> "<descrição>" [ON|OFF])
```

- `nome`: o nome da opção. Use o nome do projeto como prefixo (`APP_LOG`) para não colidir com opções de dependências
- `descrição`: o texto exibido no `cmake -LH`
- `ON|OFF`: o valor padrão. Sem ele, a opção começa `OFF`

- O valor fica gravado no cache e continua valendo nas próximas configurações, até ser mudado com `-D`
- Mudar o padrão no `CMakeLists.txt` não afeta um diretório de build que já tem a opção no cache. Use `-DAPP_LOG=OFF` ou `--fresh`
- Só guarda `ON` ou `OFF`. Para um texto ou número, use `set(... CACHE STRING ...)` (ver `functions/projeto/set.md`)

```cmake
option(APP_LOG "Habilita as mensagens de log" OFF)

if(APP_LOG)
    target_compile_definitions(app PRIVATE APP_LOG)
endif()
```

```bash
cmake -S . -B build -DAPP_LOG=ON
```

```c
#ifdef APP_LOG
    fprintf(stderr, "conectado\n");   // só existe quando compilado com -DAPP_LOG=ON
#endif
```

> O `option` sozinho não cria macro nenhuma no C. É o `target_compile_definitions` dentro do `if` que transforma a opção em um `-DAPP_LOG` na compilação
