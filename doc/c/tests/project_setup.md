**Configurando um projeto para rodar testes**

> estrutura de pastas, test runner e `Makefile`

Para testar um projeto em C sem nenhum framework, são necessárias três peças: uma separação clara entre o código do programa e o código dos testes, um **test runner** (um segundo `main`, só para os testes) e um `Makefile` que sabe gerar dois executáveis a partir dos mesmos arquivos: o programa e a suíte de testes. Com isso, `make test` compila só o que mudou e roda todos os testes com um comando

---

**Estrutura de pastas**

```text
projeto/
├── Makefile
├── compile_flags.txt        flags para o clangd (LSP) achar os headers
├── .gitignore               ignora build/
├── src/
│   ├── main.c               main do programa
│   ├── lista/
│   │   ├── lista.c
│   │   └── lista.h
│   └── utils/
│       ├── utils.c
│       └── utils.h
├── tests/
│   ├── test_runner.c        main dos testes: chama todas as funções de teste
│   ├── test_lista.c         testes do módulo lista
│   └── test_utils.c         testes do módulo utils
└── build/                   gerado pelo make, nunca versionado
    ├── app
    ├── test_suite
    ├── lista/lista.o
    ├── utils/utils.o
    ├── main.o
    └── tests/test_lista.o ...
```

- Cada módulo do `src/` tem um arquivo de teste correspondente em `tests/`, com o prefixo `test_`
- O `build/` espelha a estrutura do `src/`, assim dois arquivos com o mesmo nome em pastas diferentes não geram o mesmo `.o`

---

**O problema dos dois main**

Um executável só pode ter um `main`. O programa usa o `src/main.c`, e a suíte de testes usa o `tests/test_runner.c`. O que muda entre os dois é a lista de `.o` entregue ao linker:

```text
app          =  main.o        + lista.o + utils.o
test_suite   =  test_runner.o + lista.o + utils.o + test_lista.o + test_utils.o
```

- O código dos módulos (`lista.o`, `utils.o`) é compilado **uma vez** e usado pelos dois executáveis
- O `src/main.c` fica de fora da suíte de testes, senão o linker acusa `multiple definition of 'main'` (ver `../compilers/gcc/cheatsheet/common-errors.md`)
- Por isso o `main.c` deve ter só a inicialização do programa. Toda lógica que precisa ser testada fica nos módulos, pois o que está no `main.c` não pode ser testado

---

**Arquivos de teste**

Cada arquivo de teste tem funções sem argumentos que usam `assert` (ver `assert.md`) e não tem `main`:

```c
// tests/test_lista.c
#include <assert.h>
#include "lista/lista.h"   // achado por causa do -Isrc

void test_lista_deve_iniciar_vazia(void) {
  struct lista *l = lista_criar();
  assert(l != NULL);
  assert(lista_tamanho(l) == 0);
  lista_destruir(l);
}

void test_lista_deve_adicionar_no_final(void) {
  struct lista *l = lista_criar();
  lista_adicionar(l, 10);
  assert(lista_tamanho(l) == 1);
  assert(lista_obter(l, 0) == 10);
  lista_destruir(l);
}
```

- Os nomes descrevem o comportamento esperado (`test_<módulo>_deve_<comportamento>`), então a saída do runner já funciona como uma lista do que o código faz
- As funções não são `static`, pois o runner, que está em outro arquivo, precisa chamá-las

---

**Test runner**

```c
// tests/test_runner.c
#include <stdio.h>
#include "tests.h"

#define RUN_TEST(test_func)                \
  do {                                     \
    printf("[RUN] %s\n", #test_func);      \
    test_func();                           \
    printf("      ok\n");                  \
  } while (0)

int main(void) {
  printf("== lista ==\n");
  RUN_TEST(test_lista_deve_iniciar_vazia);
  RUN_TEST(test_lista_deve_adicionar_no_final);

  printf("== utils ==\n");
  RUN_TEST(test_utils_deve_remover_espacos);

  printf("todos os testes passaram\n");
  return 0;
}
```

```c
// tests/tests.h — declarações de todas as funções de teste
#ifndef TESTS_H
#define TESTS_H

void test_lista_deve_iniciar_vazia(void);
void test_lista_deve_adicionar_no_final(void);
void test_utils_deve_remover_espacos(void);

#endif
```

- `#test_func` transforma o nome da função em texto, e o `RUN_TEST` mostra qual teste está rodando antes de chamá-lo. Se um `assert` falhar, a última linha `[RUN]` na tela indica o teste e a mensagem do `assert` indica a linha (ver `../macros/stringify.md`)
- O `do { ... } while (0)` faz a macro funcionar como um único comando (ver `../macros/do_while_0.md`)
- Declarar os testes em um header (`tests.h`), em vez de repetir os protótipos no runner, faz o compilador conferir que a declaração e a definição batem: cada `test_*.c` também inclui o `tests.h`
- Use `(void)` nos protótipos: em C antes do C23, `void f()` significa "argumentos não especificados", e o compilador não confere a chamada

---

**Makefile**

```make
CC      = gcc
CFLAGS  = -g -Wall -Wextra -Isrc -MMD -MP
TEST_CFLAGS = $(CFLAGS) -fsanitize=address,undefined
TEST_LDFLAGS = -fsanitize=address,undefined

SRC_DIR   = src
TEST_DIR  = tests
BUILD_DIR = build

TARGET      = $(BUILD_DIR)/app
TEST_TARGET = $(BUILD_DIR)/test_suite

# todos os .c do src/, inclusive em subpastas
SRCS = $(shell find $(SRC_DIR) -name '*.c')
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# para os testes: o src/ sem o main.c, mais os arquivos de tests/
SRCS_FOR_TESTS = $(filter-out $(SRC_DIR)/main.c, $(SRCS))
TEST_SRCS      = $(shell find $(TEST_DIR) -name '*.c')
TEST_OBJS      = $(SRCS_FOR_TESTS:$(SRC_DIR)/%.c=$(BUILD_DIR)/test-obj/%.o) \
                 $(TEST_SRCS:$(TEST_DIR)/%.c=$(BUILD_DIR)/test-obj/tests/%.o)

build: $(TARGET)

run: build
	./$(TARGET)

test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TARGET): $(OBJS)
	$(CC) $^ -o $@

$(TEST_TARGET): $(TEST_OBJS)
	$(CC) $(TEST_LDFLAGS) $^ -o $@

# objetos do programa
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# objetos dos testes (src/ recompilado com sanitizers)
$(BUILD_DIR)/test-obj/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(TEST_CFLAGS) -c $< -o $@

$(BUILD_DIR)/test-obj/tests/%.o: $(TEST_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(TEST_CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

-include $(OBJS:.o=.d) $(TEST_OBJS:.o=.d)

.PHONY: build run test clean
```

- `$(shell find ...)`: encontra os `.c` automaticamente, então um módulo ou teste novo entra no build sem editar o `Makefile`
- `$(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)`: troca o prefixo e a extensão de cada caminho (`src/lista/lista.c` → `build/lista/lista.o`)
- `$(filter-out $(SRC_DIR)/main.c, ...)`: remove o `main.c` da lista dos testes, resolvendo o problema dos dois `main`
- `@mkdir -p $(dir $@)`: cria a subpasta do `.o` dentro do `build/` antes de compilar. `$@` é o alvo, `$<` é o primeiro pré-requisito e `$^` são todos os pré-requisitos
- `-Isrc`: permite incluir headers pelo caminho a partir do `src/` (`#include "lista/lista.h"`), tanto no código quanto nos testes
- `-MMD -MP` e o `-include` no final: o compilador gera um arquivo `.d` para cada `.o`, listando os headers que ele inclui. Sem isso, mudar um `.h` não recompila os `.c` que o usam, e os testes rodam com código antigo
- **Objetos separados para os testes** (`build/test-obj/`): os testes são compilados com sanitizers, que mudam o código gerado. Usar os mesmos `.o` do programa misturaria objetos com e sem instrumentação. Se não quiser sanitizers, os testes podem reaproveitar os `.o` do programa (`$(BUILD_DIR)/%.o`)
- Nunca adicione `-DNDEBUG` às flags dos testes, ou todos os `assert` somem (ver `ndebug.md`)

---

**Comandos**

```sh
make            # compila o programa em build/app
make run        # compila e roda o programa
make test       # compila e roda a suíte de testes
make clean      # apaga o build/
```

- O `make test` termina com o código de saída da suíte: `0` se todos passaram, diferente de `0` se algum `assert` falhou. Isso permite usar o mesmo comando em um hook de git ou em um CI

---

**Arquivos de apoio**

```text
# compile_flags.txt — uma flag por linha, lido pelo clangd
-Isrc
-Wall
-Wextra
```

- Sem ele, o LSP não sabe do `-Isrc` e marca como erro todo `#include "lista/lista.h"`, tanto no `src/` quanto no `tests/`. Projetos maiores costumam gerar um `compile_commands.json` (com `bear -- make` ou pelo CMake) em vez disso

```text
# .gitignore
build/
```

> Esse arranjo cresce bem até projetos médios. Quando o runner ficar grande demais para manter à mão, os próximos passos são separar uma suíte por módulo (um executável de teste para cada `test_*.c`, cada um com seu próprio `main`), ou adotar um framework (Unity, cmocka, Criterion), que registra os testes automaticamente e mostra o valor esperado e o recebido em cada falha (ver `unit_tests.md`)
