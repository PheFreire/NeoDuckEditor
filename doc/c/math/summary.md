**math.h**

> `math.h`

A `math.h` é a biblioteca de matemática do C, com funções para potência, raiz, logaritmo, arredondamento, trigonometria e classificação de números de ponto flutuante, todas trabalhando com `double` por padrão e com versões para `float` e `long double`

> Um número de `ponto flutuante` (`float`, `double`, `long double`) guarda valores com casas decimais em binário, com precisão limitada: cerca de 7 dígitos no `float` e 15 no `double`. Por isso quase todo resultado da `math.h` é uma aproximação, e não o valor matemático exato

```c
#include <math.h>
```

```sh
gcc main.c -o programa -lm
```

- No Linux, as funções da `math.h` ficam em uma biblioteca separada (`libm`), e é preciso passar `-lm` no final do comando de compilação. Sem ele, o erro é `undefined reference to 'sqrt'`
- No macOS, a `libm` já faz parte da biblioteca padrão e o `-lm` não é necessário, mas também não atrapalha
- Uma chamada com valores constantes (`sqrt(16.0)`) pode ser calculada pelo próprio compilador e compilar sem o `-lm`, enquanto `sqrt(x)` com uma variável falha, o que confunde. Na dúvida, sempre passe `-lm`

**Versões para cada tipo**

Toda função existe em três versões, diferenciadas por um sufixo no nome:

- sem sufixo: recebe e devolve `double` (`sqrt`, `pow`, `sin`)
- sufixo `f`: recebe e devolve `float` (`sqrtf`, `powf`, `sinf`)
- sufixo `l`: recebe e devolve `long double` (`sqrtl`, `powl`, `sinl`)

```c
double d = sqrt(2.0);   // 1.4142135623730951
float f = sqrtf(2.0f);  // 1.4142135
```

> Passar um `float` para a versão `double` funciona (ele é convertido), mas faz a conta com mais precisão do que o necessário. Em código que usa só `float`, como jogos e gráficos, as versões com `f` são mais coerentes

**Erros**

As funções não param o programa quando recebem um valor inválido. Elas devolvem um valor especial:

- `NAN` ("not a number"): quando a operação não tem resultado real, como `sqrt(-1)` ou `log(-1)` (erro de domínio)
- `HUGE_VAL` / `INFINITY`: quando o resultado é grande demais para o tipo, como `exp(1000)`, ou é infinito, como `log(0)` (erro de intervalo)

Em algumas plataformas (como o glibc), essas funções também ajustam o `errno` para `EDOM` ou `ERANGE`, mas outras (como o macOS) não, então a forma portável de detectar um erro é checar o resultado com `isnan` ou `isinf` (em `classification/isnan_isinf.md`)

**Cuidado com a divisão inteira**

As funções da `math.h` recebem `double`, mas uma conta entre inteiros é feita como inteiro antes de ser convertida:

```c
double r1 = sqrt(7 / 2);   // sqrt(3)   = 1.73..., pois 7 / 2 == 3 em inteiro
double r2 = sqrt(7.0 / 2); // sqrt(3.5) = 1.87...
```

Docs deste diretório:

- `constants.md`: `M_PI`, `M_E`, `NAN`, `INFINITY`, `HUGE_VAL`
- `arithmetic/`: `fabs`, `fmod`, `fmin` / `fmax`
- `rounding/`: `ceil`, `floor`, `round`, `trunc`
- `power/`: `pow`, `sqrt`, `cbrt`, `hypot`
- `exponential/`: `exp`, `log`
- `trigonometry/`: `sin` / `cos` / `tan`, `asin` / `acos` / `atan`, `atan2`
- `classification/`: `isnan` / `isinf`, comparação de números de ponto flutuante

> Diferente das operações com inteiros, que são exatas até estourar, as funções da `math.h` trabalham com aproximações, então o resultado pode diferir do esperado na última casa decimal. Por isso nunca se compara um resultado de ponto flutuante com `==`, como explicado em `classification/float_compare.md`
