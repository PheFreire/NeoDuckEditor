**sqrt**

> `math.h`

O `sqrt` (de "square root") calcula a raiz quadrada de um número, ou seja, o valor positivo que multiplicado por ele mesmo dá o número original

> A raiz quadrada de `x` é o número `r` tal que `r * r == x`: a raiz de `25` é `5`. Todo número positivo tem duas raízes (`5` e `-5`), e o `sqrt` devolve sempre a positiva

```c
double sqrt(double x);
float sqrtf(float x);
long double sqrtl(long double x);
```

- `x`: o número cuja raiz será calculada

- Devolve a raiz quadrada positiva de `x`
- `sqrt(0)` é `0`, e `sqrt(INFINITY)` é `INFINITY`
- Se `x` for negativo, não existe raiz real, e o resultado é `NAN` (erro de domínio)
- É mais rápido e mais preciso que `pow(x, 0.5)`, pois a maioria dos processadores tem uma instrução própria para ele

```c
sqrt(25.0);   // 5.0
sqrt(2.0);    // 1.4142135623730951
sqrt(0.25);   // 0.5
sqrt(-4.0);   // nan
```

**Distância entre dois pontos**

O uso mais comum: pelo teorema de Pitágoras, a distância é a raiz da soma dos quadrados das diferenças:

```c
double distancia(double x1, double y1, double x2, double y2) {
  double dx = x2 - x1;
  double dy = y2 - y1;
  return sqrt(dx * dx + dy * dy);
}

distancia(0, 0, 3, 4); // 5.0
```

> Para esse cálculo também existe o `hypot`, que evita overflow com valores muito grandes

**Comparando distâncias sem sqrt**

Como a raiz preserva a ordem (se `a < b`, então `sqrt(a) < sqrt(b)`), para só comparar distâncias não é preciso calcular a raiz, o que economiza tempo em laços com muitos pontos:

```c
double raio = 10.0;
double dx = px - cx;
double dy = py - cy;

if (dx * dx + dy * dy <= raio * raio) {
  // o ponto está dentro do círculo
}
```

**Checando se um número é quadrado perfeito**

```c
int eh_quadrado(int n) {
  int r = (int)round(sqrt(n));
  return r * r == n;
}

eh_quadrado(49); // 1
eh_quadrado(50); // 0
```

> O `round` antes do cast é importante: `sqrt(49)` poderia em teoria dar `6.9999999` por causa da precisão, e o cast cortaria para `6`. Arredondar e depois conferir com a multiplicação inteira, que é exata, evita esse erro

> Diferente do `cbrt`, que aceita negativos (`cbrt(-8)` é `-2`), o `sqrt` de um negativo é sempre `NAN`, então valores que podem ser negativos por erro de arredondamento (como `1 - x * x` com `x` muito perto de `1`) devem ser protegidos com `fmax(valor, 0.0)` antes da chamada
