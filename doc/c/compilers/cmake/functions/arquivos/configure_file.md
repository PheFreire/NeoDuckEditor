**configure_file**

> comando nativo do CMake, não precisa de include

O `configure_file` copia um arquivo modelo trocando cada `@VARIAVEL@` pelo valor da variável do CMake, sendo usado principalmente para gerar um header com a versão e as opções do projeto

```cmake
configure_file(<entrada> <saída> [@ONLY] [COPYONLY])
```

- `entrada`: o arquivo modelo, relativo ao diretório do `CMakeLists.txt`. Por convenção termina em `.in`
- `saída`: o arquivo gerado, relativo ao diretório de build correspondente
- `@ONLY`: troca só `@VARIAVEL@` e deixa `${VARIAVEL}` como está. Use sempre em arquivos de C
- `COPYONLY`: copia sem trocar nada

- `#cmakedefine NOME` vira `#define NOME` quando a variável `NOME` é verdadeira, e `/* #undef NOME */` quando não é
- `#cmakedefine01 NOME` vira `#define NOME 1` ou `#define NOME 0`
- O arquivo é gerado no configure e é gerado de novo quando o modelo muda
- A saída fica no diretório de build, então esse diretório precisa ir para o `target_include_directories`

```c
// src/config.h.in
#define APP_NOME "@PROJECT_NAME@"
#define APP_VERSAO "@PROJECT_VERSION@"
#cmakedefine APP_LOG
```

```cmake
configure_file(src/config.h.in config.h @ONLY)
target_include_directories(app PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
```

```c
// build/config.h gerado com -DAPP_LOG=ON
#define APP_NOME "app"
#define APP_VERSAO "1.0.0"
#define APP_LOG
```

> Não coloque o arquivo gerado no git nem no diretório do código. Ele depende das opções de cada diretório de build, e o modelo `.in` é a fonte de verdade
