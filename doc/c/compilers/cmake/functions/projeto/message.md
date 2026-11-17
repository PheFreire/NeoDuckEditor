**message**

> comando nativo do CMake, não precisa de include

O `message` imprime um texto durante o configure, servindo para mostrar o que o CMake encontrou, avisar sobre um problema ou parar o configure com erro

```cmake
message([<modo>] "<texto>")
```

- `modo`: o tipo da mensagem
	- `STATUS`: uma linha começando com `-- `, para informar
	- `WARNING`: um aviso com o arquivo e a linha. O configure continua
	- `FATAL_ERROR`: para o configure na hora, e nenhum arquivo de build é gerado
	- `VERBOSE` / `DEBUG`: só aparecem com `cmake --log-level=VERBOSE` ou `DEBUG`
	- sem modo: o texto sai simples, como um aviso
- `texto`: a mensagem. Variáveis dentro das aspas são expandidas

- Roda no configure, e não no build. Não aparece no `cmake --build`, a não ser que o build reconfigure o projeto
- É a forma de depurar um `CMakeLists.txt`: imprimir o valor de uma variável no ponto em que ela é usada

```cmake
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")     # -- Build type: Debug
message(STATUS "Compilador: ${CMAKE_C_COMPILER_ID}")   # -- Compilador: GNU

if(NOT CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    message(FATAL_ERROR "Compilador não suportado: ${CMAKE_C_COMPILER_ID}")
endif()
```
