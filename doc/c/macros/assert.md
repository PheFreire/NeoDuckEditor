**assert / static_assert**

> `assert.h`

O `assert` é uma macro que verifica uma condição enquanto o programa roda e, se ela for falsa, imprime a expressão, o arquivo e a linha que falharam e encerra o programa na hora, sendo usado para garantir suposições que nunca deveriam ser quebradas

> Um `assert` não é tratamento de erro: ele serve para pegar bugs do programador ("este ponteiro nunca deveria ser `NULL` aqui"), e não para situações que podem acontecer normalmente, como um arquivo que não existe ou uma entrada inválida do usuário, que devem ser tratadas com `if`

```c
void assert(scalar expressão);
```

- `expressão`: a condição que deve ser verdadeira. Se for `0`, o programa é encerrado

- Se a condição for verdadeira, não faz nada
- Se for falsa, escreve no `stderr` uma mensagem com a expressão (obtida com o operador `#`), o arquivo, a linha e a função, e chama o `abort()`, encerrando o programa
- O formato exato da mensagem depende da biblioteca, mas sempre contém essas informações

```c
#include <assert.h>

int dividir(int a, int b) {
  assert(b != 0);
  return a / b;
}

dividir(10, 0);
// Linux:  programa: main.c:4: dividir: Assertion `b != 0' failed.
// macOS:  Assertion failed: (b != 0), function dividir, file main.c, line 4.
// e o programa é encerrado (Aborted)
```

---

**Desligando com NDEBUG**

Se a macro `NDEBUG` estiver definida antes do `#include <assert.h>`, todo `assert` vira `((void)0)` e some do programa, o que é comum em builds de produção:

```sh
gcc main.c -o programa           # asserts ativos
gcc -DNDEBUG main.c -o programa  # asserts removidos
```

Por isso, nunca se deve colocar dentro de um `assert` algo que precisa acontecer:

```c
assert(fclose(file) == 0); // com -DNDEBUG, o fclose nunca é chamado

int r = fclose(file);      // correto: a ação acontece sempre
assert(r == 0);            // e só a checagem some
```

---

**Mensagem junto com a condição**

O `assert` não aceita uma mensagem, mas como uma string literal é sempre verdadeira, ela pode ser adicionada com `&&` e aparece no texto do erro:

```c
assert(indice < total && "indice fora do limite");
// Assertion `indice < total && "indice fora do limite"' failed.
```

---

**static_assert**

Verifica uma condição durante a compilação, e não enquanto o programa roda: se ela for falsa, o programa nem chega a ser compilado

```c
static_assert(expressão_constante, "mensagem");
```

- `expressão_constante`: precisa ser conhecida na compilação, como `sizeof`, constantes e macros. Variáveis não são permitidas
- `"mensagem"`: o texto do erro de compilação. No C23 passou a ser opcional
- Disponível desde o C11 (como `_Static_assert`, ou `static_assert` incluindo `assert.h`). No C23 virou palavra-chave e não precisa mais de header
- Não gera nenhum código, então não tem custo nenhum e não é afetado por `NDEBUG`

```c
static_assert(sizeof(int) == 4, "este código assume int de 4 bytes");

struct cabecalho {
  uint32_t tipo;
  uint32_t tamanho;
};

static_assert(sizeof(struct cabecalho) == 8, "cabecalho deve ter 8 bytes, sem padding");
```

> Diferente do `assert`, que só descobre o problema quando aquela linha é executada, o `static_assert` impede o programa errado de ser compilado. Sempre que a condição puder ser checada na compilação, ele é a melhor opção, deixando o `assert` para o que só se sabe com o programa rodando
