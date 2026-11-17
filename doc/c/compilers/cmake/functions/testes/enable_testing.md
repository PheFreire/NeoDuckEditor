**enable_testing**

> comando nativo do CMake, não precisa de include

O `enable_testing` ativa os testes no diretório atual e nos subdiretórios abaixo dele, para que o `ctest` encontre os testes registrados com `add_test`

```cmake
enable_testing()
include(CTest)
```

- Não recebe argumentos
- Precisa estar no `CMakeLists.txt` raiz, antes do `add_subdirectory` dos testes. Sem ele, o `ctest` diz `No tests were found`
- O `include(CTest)` chama o `enable_testing` e também cria a opção `BUILD_TESTING` (`ON` por padrão), que desliga os testes com `-DBUILD_TESTING=OFF`

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)

add_subdirectory(src)

if(PROJECT_IS_TOP_LEVEL)
    enable_testing()
    add_subdirectory(tests)
endif()
```

> O `PROJECT_IS_TOP_LEVEL` evita compilar os testes quando o projeto é usado como dependência de outro, com `add_subdirectory` ou `FetchContent`
