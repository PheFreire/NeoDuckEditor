**cbrt**

> `math.h`

O `cbrt` (de "cube root") calcula a raiz cúbica de um número, ou seja, o valor que multiplicado por ele mesmo três vezes dá o número original, funcionando também com números negativos

> A raiz cúbica de `x` é o número `r` tal que `r * r * r == x`: a raiz cúbica de `27` é `3`. Diferente da raiz quadrada, números negativos têm raiz cúbica real, já que `(-3) * (-3) * (-3) == -27`

```c
double cbrt(double x);
float cbrtf(float x);
long double cbrtl(long double x);
```

- `x`: o número cuja raiz cúbica será calculada

- Devolve a raiz cúbica de `x`, com o mesmo sinal de `x`
- Nunca gera erro de domínio, pois todo número real tem raiz cúbica real

```c
cbrt(27.0);   // 3.0
cbrt(-8.0);   // -2.0
cbrt(2.0);    // 1.2599210498948732
```

**cbrt x pow**

O `pow` com expoente `1.0 / 3` não funciona para negativos, e para positivos pode ser menos preciso:

```c
cbrt(-8.0);           // -2.0
pow(-8.0, 1.0 / 3);   // nan, base negativa com expoente fracionário

pow(27.0, 1.0 / 3);   // 3.0 (aproximadamente), já que 1.0 / 3 não é exatamente um terço
```

**Lado de um cubo a partir do volume**

```c
double volume = 125.0;
double lado = cbrt(volume); // 5.0
```

> Diferente do `sqrt`, que devolve `NAN` para negativos, o `cbrt` aceita qualquer número real. Além disso, diferente de `pow(x, 1.0 / 3)`, ele é exato para cubos perfeitos e trata o sinal corretamente, por isso é sempre a forma certa de calcular raízes cúbicas
