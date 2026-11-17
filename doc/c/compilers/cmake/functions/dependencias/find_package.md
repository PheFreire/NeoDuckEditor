**find_package**

> comando nativo do CMake, não precisa de include

O `find_package` procura uma biblioteca instalada no sistema e, quando a encontra, cria targets importados (`Pacote::nome`) que já carregam o diretório dos headers e o arquivo da biblioteca, prontos para o `target_link_libraries`

```cmake
find_package(<pacote> [<versão>] [REQUIRED] [COMPONENTS <componente>...] [QUIET])
```

- `pacote`: o nome do pacote, como `Threads` ou `Fila`
- `versão`: a versão mínima aceita, como `1.2`
- `REQUIRED`: para o configure com erro se o pacote não for encontrado
- `COMPONENTS`: as partes do pacote que o projeto usa, quando ele é dividido em várias bibliotecas
- `QUIET`: não imprime nada quando o pacote não é encontrado

- Cria a variável `<pacote>_FOUND`, verdadeira quando encontrou. Sem `REQUIRED`, teste ela com `if`
- Procura de duas formas: por um módulo do CMake (`Find<pacote>.cmake`) ou por um arquivo de configuração instalado pela própria biblioteca (`<pacote>Config.cmake`)
- O nome do target criado varia de pacote para pacote. A documentação de um módulo do CMake mostra os nomes: `cmake --help-module FindThreads`
- Para uma biblioteca instalada fora dos diretórios padrão, passe o prefixo no configure: `-DCMAKE_PREFIX_PATH=/opt/fila`

```cmake
find_package(Threads REQUIRED)                 # pthread em qualquer sistema
find_package(Fila 1.2 REQUIRED)                # instalada com um FilaConfig.cmake

add_executable(app main.c)
target_link_libraries(app PRIVATE Threads::Threads Fila::fila)
```

```cmake
find_package(Fila QUIET)
if(Fila_FOUND)
    target_link_libraries(app PRIVATE Fila::fila)
    target_compile_definitions(app PRIVATE USAR_FILA)
endif()
```

> Quando a biblioteca não tem `Find<pacote>.cmake` nem `<pacote>Config.cmake`, o `find_package` não a encontra. Nesse caso, procure o arquivo e o header com `find_library` e `find_path` (ver `functions/dependencias/find_library.md`)
