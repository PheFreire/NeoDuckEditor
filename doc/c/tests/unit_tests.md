**Testes unitários com assert**

> testes em C só com `assert.h`

Um teste unitário é uma função que chama uma parte pequena do código com entradas conhecidas e verifica se o resultado é o esperado. Em C, a forma mais simples de escrever testes não precisa de nenhuma biblioteca: um programa separado, com uma função por caso de teste, usando `assert` para verificar cada resultado

**Estrutura**

```text
projeto/
├── src/
│   ├── lista.c        código que será testado
│   └── lista.h
└── tests/
    └── test_lista.c   programa de testes, com seu próprio main
```

- O programa de testes é compilado junto com o código testado, mas **sem** o `main` do programa principal
- Cada teste é uma função `static void test_...(void)`, e o `main` dos testes chama todas elas em sequência

```c
// tests/test_lista.c
#include <assert.h>
#include <stdio.h>
#include "../src/lista.h"

static void test_lista_vazia(void) {
  struct lista *l = lista_criar();
  assert(l != NULL);
  assert(lista_tamanho(l) == 0);
  lista_destruir(l);
}

static void test_adicionar(void) {
  struct lista *l = lista_criar();
  lista_adicionar(l, 10);
  lista_adicionar(l, 20);
  assert(lista_tamanho(l) == 2);
  assert(lista_obter(l, 0) == 10);
  assert(lista_obter(l, 1) == 20);
  lista_destruir(l);
}

int main(void) {
  test_lista_vazia();
  test_adicionar();
  printf("todos os testes passaram\n");
  return 0;
}
```

```sh
gcc -g -Wall -Wextra -fsanitize=address,undefined src/lista.c tests/test_lista.c -o test_lista
./test_lista
```

- `-g`: o debugger e os sanitizers mostram arquivo e linha da falha
- `-fsanitize=address,undefined`: além dos `assert`, detecta erros de memória e comportamento indefinido durante os testes (ver `../compilers/gcc/cheatsheet/sanitizers.md`)
- Nunca compile os testes com `-DNDEBUG`: todos os `assert` somem e os testes passam sem verificar nada (ver `ndebug.md`)

**Como o resultado é lido**

```text
tudo certo:   todos os testes passaram         código de saída 0
falha:        test_lista: tests/test_lista.c:17: test_adicionar: Assertion `lista_tamanho(l) == 2' failed.
              Aborted                          código de saída 134
```

- A mensagem já diz qual função de teste e qual linha falharam, sem precisar de nenhuma ferramenta extra
- O código de saída é o que scripts, o `make` e sistemas de CI usam para saber se os testes passaram: `0` é sucesso, qualquer outro valor é falha

```make
test: test_lista
	./test_lista

test_lista: src/lista.c tests/test_lista.c
	gcc -g -Wall -Wextra -fsanitize=address,undefined $^ -o $@
```

**Limitação: para no primeiro erro**

O `assert` encerra o programa na primeira falha, então os testes seguintes nem rodam. Para ver todas as falhas de uma vez, é comum criar uma macro própria que registra o erro e continua:

```c
#include <stdio.h>

static int falhas = 0;

#define CHECK(cond)                                                   \
  do {                                                                \
    if (!(cond)) {                                                    \
      fprintf(stderr, "%s:%d: %s: falhou: %s\n",                      \
              __FILE__, __LINE__, __func__, #cond);                   \
      falhas++;                                                       \
    }                                                                 \
  } while (0)

int main(void) {
  test_lista_vazia();
  test_adicionar();
  if (falhas > 0) {
    fprintf(stderr, "%d verificação(ões) falharam\n", falhas);
    return 1;
  }
  printf("todos os testes passaram\n");
  return 0;
}
```

- `#cond`, `__FILE__`, `__LINE__` e `__func__` reproduzem a mensagem do `assert` (ver `assert.md`)
- O `do { ... } while (0)` faz a macro se comportar como um único comando, inclusive dentro de um `if` sem chaves (ver `../macros/do_while_0.md`)
- Os frameworks de teste costumam ter os dois tipos: `ASSERT_*`, que interrompe o teste atual ao falhar (como o `assert`), e `EXPECT_*` ou `CHECK`, que registra a falha e continua
- Use o `assert` para condições sem as quais o resto do teste não faz sentido (como a lista ser `NULL`) e o `CHECK` para os valores comparados

**Boas práticas**

- Um teste verifica um único comportamento, e o nome da função diz qual: `test_adicionar_em_lista_cheia`, e não `test2`
- Cada teste cria e destrói os próprios dados, sem depender da ordem ou do resultado de outros testes
- Teste os casos de borda: lista vazia, um elemento, capacidade máxima, índices `0` e `n - 1`, `NULL`, strings vazias
- Para ponto flutuante, compare com uma tolerância em vez de `==` (ver `../math/classification/float_compare.md`)
- Rode os testes com os sanitizers ligados: muitos bugs de memória não fazem nenhum `assert` falhar, mas são detectados por eles

> Para projetos maiores, existem frameworks de teste em C, como Unity, cmocka, Criterion e greatest, que adicionam comparações com mensagens detalhadas (mostrando o valor esperado e o recebido), descoberta automática de testes e relatórios. Todos seguem a mesma ideia mostrada aqui: funções de teste, verificações e um código de saída que indica se tudo passou
