**Comparando números de ponto flutuante**

> `math.h` (`fabs`), `float.h` (`DBL_EPSILON`)

Números de ponto flutuante não devem ser comparados com `==`, pois quase toda conta gera um pequeno erro de arredondamento. A forma correta é verificar se a diferença entre os dois valores é menor que uma tolerância (`epsilon`)

> Um `double` guarda números em binário, e a maioria das frações decimais, como `0.1`, não tem representação exata em binário, assim como `1 / 3` não tem em decimal (`0.333...`). O valor guardado é o mais próximo possível, e esses pequenos erros se acumulam a cada operação

```c
// não use:
if (a == b) { }

// use:
if (fabs(a - b) < EPSILON) { }
```

- `EPSILON`: a diferença máxima aceita para considerar os dois valores iguais, escolhida de acordo com a escala dos números envolvidos

---

**O problema**

```c
double a = 0.1 + 0.2;
double b = 0.3;

printf("%d\n", a == b);    // 0
printf("%.17f\n", a);      // 0.30000000000000004
printf("%.17f\n", b);      // 0.29999999999999999
```

O mesmo acontece em um laço que soma frações, que pode nunca bater exatamente no valor esperado:

```c
for (double x = 0.0; x != 1.0; x += 0.1) {
  // nunca para: x passa de 0.9999999999999999 para 1.0999999999999999
}

for (double x = 0.0; x < 1.0 - 1e-9; x += 0.1) {
  // forma segura
}
```

---

**Tolerância absoluta**

Funciona bem quando os números têm uma escala conhecida, perto de `1`:

```c
#define EPSILON 1e-9

int quase_igual(double a, double b) {
  return fabs(a - b) < EPSILON;
}

quase_igual(0.1 + 0.2, 0.3); // 1
```

> Uma tolerância fixa falha com números muito grandes ou muito pequenos: para `1e20`, a menor diferença possível entre dois `double` já é maior que `1e-9`, então só valores idênticos passariam. Para `1e-12`, quase qualquer par de valores passaria

---

**Tolerância relativa**

Escala a tolerância de acordo com o tamanho dos números comparados, funcionando para qualquer ordem de grandeza:

```c
#include <float.h>
#include <math.h>

int quase_igual_rel(double a, double b) {
  double diff = fabs(a - b);
  double maior = fmax(fabs(a), fabs(b));
  return diff <= maior * DBL_EPSILON * 4;
}

quase_igual_rel(1e20, 1e20 + 1e4);  // 1, diferença insignificante para essa escala
quase_igual_rel(0.1 + 0.2, 0.3);    // 1
```

- `DBL_EPSILON` (`2.22e-16`, de `float.h`): a menor diferença relativa entre dois `double`. Multiplicá-lo por um fator pequeno (como `4`) deixa uma margem para erros acumulados em poucas operações

---

**Combinando as duas**

A tolerância relativa falha perto de zero (onde `maior` também é quase zero), então a forma mais robusta usa as duas:

```c
int quase_igual_completo(double a, double b) {
  double diff = fabs(a - b);
  if (diff < 1e-12) {
    return 1; // tolerância absoluta, para valores perto de zero
  }
  return diff <= fmax(fabs(a), fabs(b)) * 1e-9; // tolerância relativa
}

quase_igual_completo(sin(M_PI), 0.0); // 1, sin(M_PI) é 1.22e-16
```

---

**Quando == funciona**

- Comparar com valores que foram atribuídos e não calculados: `x = 0.0; if (x == 0.0)` é seguro
- Inteiros pequenos guardados em `double` são exatos (até `2⁵³`), então somas de inteiros como `2.0 + 3.0 == 5.0` são seguras
- `<` e `>` podem ser usados normalmente, desde que um resultado "quase igual" não mude a lógica do programa

> Diferente dos inteiros, onde `==` é sempre exato, com ponto flutuante a pergunta certa não é "são iguais?", mas "são próximos o suficiente para o meu problema?". A tolerância ideal depende da precisão que os dados de fato têm, e para valores que precisam ser exatos, como dinheiro, o certo é usar inteiros (centavos) em vez de `double`
