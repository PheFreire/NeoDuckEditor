**Diagnósticos**

> warnings, erros, notes e fix-its do Clang

Os warnings do Clang usam as mesmas flags do GCC (`-Wall`, `-Wextra`, `-Wpedantic`, `-Werror`, `-Wno-nome`, ver `gcc/cheatsheet/warnings.md`). O que muda é a forma das mensagens: o Clang mostra o trecho exato do código, marca a expressão inteira com `~~~`, explica a causa com `note` e muitas vezes já sugere a correção, o `fix-it`

```c
#include <stdio.h>
int main(void) {
  int x = 10;
  unsigned int u = 3;
  if (x = 5) {
    printf("%s\n", x);
  }
  return x < u;
}
```

```text
aviso.c:5:9: warning: using the result of an assignment as a condition without parentheses [-Wparentheses]
    5 |   if (x = 5) {
      |       ~~^~~
aviso.c:5:9: note: place parentheses around the assignment to silence this warning
    5 |   if (x = 5) {
      |         ^
      |       (    )
aviso.c:5:9: note: use '==' to turn this assignment into an equality comparison
    5 |   if (x = 5) {
      |         ^
      |         ==
aviso.c:6:20: warning: format specifies type 'char *' but the argument has type 'int' [-Wformat]
    6 |     printf("%s\n", x);
      |             ~~     ^
      |             %d
aviso.c:8:12: warning: comparison of integers of different signs: 'int' and 'unsigned int' [-Wsign-compare]
    8 |   return x < u;
      |          ~ ^ ~
3 warnings generated.
```

- `^` aponta a posição exata, e `~~~` sublinha as expressões envolvidas (os dois lados do `<`, a string de formato e o argumento)
- `note`: uma explicação ligada ao warning acima dela, que mostra uma forma de corrigir ou onde algo foi declarado
- A linha abaixo do `^` com texto (`(    )`, `==`, `%d`) é o `fix-it`: a mudança que o Clang sugere. Quando há mais de uma possibilidade, cada uma vem em uma `note` separada, como no `if (x = 5)`, que pode ser `((x = 5))` (a atribuição era de propósito) ou `x == 5`
- O nome entre colchetes é a flag que controla aquele aviso, igual ao GCC

---

**Fix-its**

```bash
clang -fdiagnostics-parseable-fixits -c aviso.c
```

```text
fix-it:"aviso.c":{5:7-5:7}:"("
fix-it:"aviso.c":{5:12-5:12}:")"
fix-it:"aviso.c":{5:9-5:10}:"=="
fix-it:"aviso.c":{6:13-6:15}:"%d"
```

- Cada linha diz o arquivo, o intervalo (linha e coluna de início e fim) e o texto que entra no lugar
- É isso que o `clangd` usa para oferecer as correções como `code action` no editor (ver `tooling.md`)
- Aplique com cuidado: o fix-it resolve o aviso, mas não sabe a intenção. Trocar `%s` por `%d` está certo se `x` devia ser impresso como número, e errado se o argumento é que estava trocado

---

**-Weverything**

O Clang tem uma flag que o GCC não tem: `-Weverything` liga **todos** os warnings existentes, inclusive os que são só de estilo ou que contradizem uns aos outros

```c
struct ponto { char c; int x; };

static int ler(int *v, long n) {
  int total;
  for (long i = 0; i < n; i++) {
    if (v[i] > 0) total = v[i];
  }
  int k = n;
  return total + k;
}

int px(const struct ponto *p, int *v) { return p->x + ler(v, 3); }
```

```text
# clang -Wall -Wextra: nenhum warning

# clang -Weverything:
warning: include location '/usr/local/include' is unsafe for cross-compilation [-Wpoison-system-directories]
ev.c:8:7: warning: mixing declarations and code is incompatible with standards before C99 [-Wdeclaration-after-statement]
ev.c:8:11: warning: implicit conversion loses integer precision: 'long' to 'int' [-Wshorten-64-to-32]
ev.c:9:10: warning: variable 'total' may be uninitialized when used here [-Wconditional-uninitialized]
ev.c:12:5: warning: no previous prototype for function 'px' [-Wmissing-prototypes]
ev.c:1:28: warning: padding struct 'struct ponto' with 3 bytes to align 'x' [-Wpadded]
```

- Dois desses são bugs reais que o `-Wall -Wextra` não pegou: `total` não é inicializado se nenhum `v[i]` for positivo, e `n` pode não caber em um `int`
- O `-Wmissing-prototypes` é útil em projetos com headers: aponta função global sem declaração prévia, que normalmente devia estar no `.h` ou ser `static`
- Os outros são ruído: declarar variáveis no meio do bloco é C99 válido, o padding da struct é normal e o aviso de `/usr/local/include` só importa em cross-compilation
- O uso recomendado é **descobrir** warnings: rodar `-Weverything` de vez em quando e, para cada aviso útil, adicionar a flag dele (`-Wconditional-uninitialized`, `-Wshorten-64-to-32`) ao build normal
- Quem usa `-Weverything` no build do dia a dia precisa desligar o ruído com `-Wno-`: `-Wno-padded`, `-Wno-declaration-after-statement`, `-Wno-poison-system-directories`. A cada versão nova do Clang, warnings novos aparecem e o build pode quebrar com `-Werror`

---

**Warnings úteis que só o Clang tem**

- `-Wconditional-uninitialized`: variável que pode não ter sido inicializada em algum caminho (o GCC tem algo parecido, `-Wmaybe-uninitialized`, mas que depende de otimização)
- `-Wshorten-64-to-32`: conversão de um tipo de 64 bits (`long`, `size_t`) para 32 bits (`int`). Uma parte do `-Wconversion` focada no caso que mais causa bug
- `-Wimplicit-int-conversion`, `-Wimplicit-float-conversion`: conversões implícitas que perdem valor, separadas por tipo
- `-Wunreachable-code`: código que nunca é executado, como um comando depois de um `return`
- `-Wcomma`: uso suspeito do operador vírgula, como `if (a, b)`
- `-Wassign-enum`: atribuir a um enum um valor fora da lista
- `-Wcovered-switch-default`: `default` em um `switch` que já trata todas as constantes do enum, o que impede o `-Wswitch` de avisar quando uma constante nova for adicionada
- `-Wdocumentation`: comentários de documentação (`/** @param x ... */`) que não batem com os parâmetros da função
- `-Warray-bounds`: índice constante fora do array, avisado mesmo em `-O0` (no GCC, só com otimização)

---

**Controlando no código**

```c
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
int callback(int x) { return 0; }   // sem warning
#pragma clang diagnostic pop
int outra(int y) { return 0; }      // warning: unused parameter 'y'
```

- `push` guarda o estado atual dos warnings, `ignored` desliga um deles e `pop` volta ao estado guardado, então o efeito fica limitado ao trecho entre os dois
- Também existem `warning` e `error` no lugar de `ignored`, para ligar um aviso ou transformá-lo em erro só naquele trecho
- O Clang aceita `#pragma GCC diagnostic` com a mesma sintaxe. Em código que compila nos dois, prefira a forma `GCC`
- Para um parâmetro não usado, é mais simples marcar só ele: `(void)x;` no corpo da função ou `[[maybe_unused]] int x` (C23)

---

**Erros mais rígidos por padrão**

Algumas construções que o GCC antigo deixava passar como warning são erro no Clang:

- `-Wimplicit-function-declaration`: chamar uma função sem declaração é erro a partir do Clang 16 (`call to undeclared function 'soma'; ISO C99 and later do not support implicit function declarations`)
- `-Wint-conversion`: atribuir um `int` a um ponteiro sem cast é erro a partir do Clang 15
- `-Wincompatible-function-pointer-types`: ponteiro de função com tipo incompatível é erro a partir do Clang 16
- Os três ainda podem ser rebaixados para warning com `-Wno-error=nome`, o que só faz sentido para compilar código antigo que não pode ser corrigido

> Um warning do Clang com `note` normalmente já diz como corrigir. Leia a `note` antes de silenciar o aviso: ela costuma mostrar a forma que o compilador entende como intencional, como os parênteses duplos em `if ((x = 5))`, que mantém a atribuição e deixa claro para quem lê que ela não é um `==` esquecido
