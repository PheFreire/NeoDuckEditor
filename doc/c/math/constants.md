**Constantes da math.h**

> `math.h`

A `math.h` define macros com valores especiais de ponto flutuante, como infinito e "não é um número", e, na maioria das plataformas, também constantes matemáticas como π e o número de Euler, prontas para usar sem precisar escrever os dígitos à mão

> Algumas dessas constantes fazem parte do padrão C (`NAN`, `INFINITY`, `HUGE_VAL`), e outras, como `M_PI`, vêm do POSIX: funcionam no Linux e no macOS, mas não são garantidas em todo compilador

---

**Constantes padrão (C99)**

- `INFINITY`: infinito positivo, do tipo `float`. `-INFINITY` é o negativo
- `NAN`: "not a number", um valor que representa um resultado indefinido, como `0.0 / 0.0`
- `HUGE_VAL`: o valor devolvido pelas funções `double` quando o resultado é grande demais (na prática, igual ao infinito). Existem também `HUGE_VALF` e `HUGE_VALL`

```c
double inf = INFINITY;
printf("%f\n", inf);           // inf
printf("%f\n", -inf);          // -inf
printf("%d\n", inf > 1e308);   // 1, infinito é maior que qualquer número

double nan = NAN;
printf("%f\n", nan);           // nan
printf("%d\n", nan == nan);    // 0, NAN nunca é igual a nada, nem a ele mesmo
```

> Por `NAN == NAN` ser falso, a única forma de saber se um valor é `NAN` é com a macro `isnan`, explicada em `classification/isnan_isinf.md`

---

**Constantes matemáticas (POSIX)**

- `M_PI`: π, `3.14159265358979323846`
- `M_PI_2`: π / 2
- `M_PI_4`: π / 4
- `M_E`: o número de Euler, `2.71828182845904523536`
- `M_SQRT2`: √2, `1.41421356237309504880`
- `M_LN2`: logaritmo natural de 2
- `M_LN10`: logaritmo natural de 10

```c
double raio = 2.0;
double area = M_PI * raio * raio;     // 12.566370614359172
double circunferencia = 2 * M_PI * raio;
```

- Com `-std=c99` ou `-std=c11` estritos, o glibc esconde essas constantes, e é preciso definir `_DEFAULT_SOURCE` (ou `_XOPEN_SOURCE`) antes do `#include`, ou compilar com `-std=gnu11`
- No MSVC (Windows), é preciso definir `_USE_MATH_DEFINES` antes do `#include <math.h>`

```c
#define _USE_MATH_DEFINES // MSVC
#define _DEFAULT_SOURCE   // glibc com -std=c99/c11
#include <math.h>
```

Uma forma portável de obter π sem depender do `M_PI`, já que o arco cujo cosseno é `-1` é exatamente π:

```c
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// ou, calculado em tempo de execução:
const double pi = acos(-1.0);
```

---

**Limites dos tipos (float.h)**

Valores relacionados à precisão dos tipos ficam na `float.h`, e não na `math.h`:

- `DBL_EPSILON`: a menor diferença entre `1.0` e o próximo `double` representável (`2.22e-16`). `FLT_EPSILON` para `float` (`1.19e-07`)
- `DBL_MAX` / `FLT_MAX`: o maior valor finito do tipo (`1.79e+308` / `3.40e+38`)
- `DBL_MIN` / `FLT_MIN`: o menor valor positivo normalizado do tipo (`2.23e-308` / `1.18e-38`)

> Diferente das constantes inteiras de `limits.h` (`INT_MAX`), que marcam onde um inteiro estoura e dá a volta, ultrapassar `DBL_MAX` não dá a volta: o resultado vira `INFINITY`, e operações sem sentido viram `NAN`, que se propagam por todas as contas seguintes
