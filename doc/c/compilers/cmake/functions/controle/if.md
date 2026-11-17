**if**

> comando nativo do CMake, não precisa de include

O `if` executa um bloco de comandos só quando uma condição é verdadeira, sendo usado para configurar o build conforme as opções, o sistema operacional, o compilador ou a existência de algo

```cmake
if(<condição>)
    ...
elseif(<condição>)
    ...
else()
    ...
endif()
```

- `condição`: uma variável, uma comparação ou um teste
	- `NOT`, `AND`, `OR` e parênteses para combinar
	- `EQUAL`, `LESS`, `GREATER`: compara números
	- `STREQUAL`: compara textos
	- `VERSION_LESS`, `VERSION_GREATER_EQUAL`: compara versões como `3.20.1`
	- `MATCHES`: testa uma expressão regular
	- `DEFINED VAR`, `EXISTS caminho`, `TARGET nome`: testa se existe

- Variáveis aparecem sem `${}`: `if(APP_LOG)`, e não `if(${APP_LOG})`
- São verdadeiros `ON`, `YES`, `TRUE`, `Y` e números diferentes de `0`. São falsos `OFF`, `NO`, `FALSE`, `0`, o texto vazio e tudo que termina em `-NOTFOUND`
- Variáveis prontas para o sistema e o compilador: `WIN32`, `APPLE`, `UNIX`, `LINUX` (3.25+) e `CMAKE_C_COMPILER_ID` (`GNU`, `Clang`, `AppleClang`, `MSVC`)
- O `if` roda no configure. Ele decide quais comandos rodam, e não o que acontece no código C

```cmake
option(APP_LOG "Habilita log" OFF)

if(APP_LOG)
    target_compile_definitions(app PRIVATE APP_LOG)
endif()

if(APPLE)
    target_sources(app PRIVATE src/plataforma_mac.c)
elseif(UNIX)
    target_sources(app PRIVATE src/plataforma_linux.c)
endif()

if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(app PRIVATE -Wall -Wextra)
endif()
```

> Evite `if(CMAKE_BUILD_TYPE STREQUAL "Debug")` para mudar flags. Em geradores com vários build types no mesmo diretório (Xcode, Visual Studio), essa variável fica vazia. A forma que funciona em todos é a generator expression `$<$<CONFIG:Debug>:...>` dentro do comando `target_*`
