**add_test**

> comando nativo do CMake, não precisa de include

O `add_test` registra um comando como teste, que o `ctest` executa e considera aprovado quando o programa termina com código de saída `0`

```cmake
add_test(NAME <nome> COMMAND <comando> [<argumento>...] [WORKING_DIRECTORY <diretório>])
set_tests_properties(<nome>... PROPERTIES <propriedade> <valor>...)
```

- `NAME`: o nome do teste, exibido pelo `ctest` e usado no filtro `-R`
- `COMMAND`: o programa a executar. Quando é o nome de um target, o CMake troca pelo caminho do executável
- `argumento`: argumentos passados ao programa
- `WORKING_DIRECTORY`: o diretório em que o teste roda. O padrão é o diretório de build correspondente
- `set_tests_properties`: muda propriedades do teste
	- `TIMEOUT`: segundos até o teste ser interrompido
	- `WILL_FAIL`: `ON` inverte o resultado, para testes que devem falhar
	- `ENVIRONMENT`: variáveis de ambiente, como `"MODO=teste"`
	- `LABELS`: rótulos para filtrar com `ctest -L`

- Só funciona depois de um `enable_testing` no `CMakeLists.txt` raiz
- O `ctest` não compila nada. Rode o `cmake --build build` antes

```cmake
# tests/CMakeLists.txt
add_executable(test_lista test_lista.c)
target_link_libraries(test_lista PRIVATE lista)

add_test(NAME lista COMMAND test_lista)
add_test(NAME lista_arquivo COMMAND test_lista ${PROJECT_SOURCE_DIR}/tests/dados.txt)
set_tests_properties(lista_arquivo PROPERTIES TIMEOUT 5)
```

```c
// tests/test_lista.c
#include <assert.h>
#include "lista/lista.h"

int main(void) {
    Lista *l = lista_criar();
    lista_inserir(l, 10);
    assert(lista_tamanho(l) == 1);   // se falhar, o programa aborta e o teste falha
    lista_destruir(l);
    return 0;                        // 0: teste aprovado
}
```

> O `assert` é desligado pelo `-DNDEBUG` dos builds `Release`, `RelWithDebInfo` e `MinSizeRel`. Rode os testes em um build `Debug`, ou eles passam sem testar nada
