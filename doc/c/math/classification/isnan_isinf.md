**isnan / isinf / isfinite**

> `math.h`

O `isnan`, o `isinf` e o `isfinite` são macros que verificam se um número de ponto flutuante é `NAN`, infinito ou um número comum (finito), sendo a forma de detectar quando uma conta da `math.h` deu errado

> Um `double` pode guardar, além de números comuns, três valores especiais: `+INFINITY`, `-INFINITY` e `NAN` ("not a number"). Eles surgem de contas como `1.0 / 0.0` (infinito), `0.0 / 0.0` ou `sqrt(-1)` (`NAN`), e se espalham por todas as contas seguintes que os usarem

```c
int isnan(x);
int isinf(x);
int isfinite(x);
int signbit(x);
```

- `x`: um valor `float`, `double` ou `long double`. Por serem macros, funcionam com os três tipos

- `isnan(x)`: diferente de `0` se `x` for `NAN`
- `isinf(x)`: diferente de `0` se `x` for `+INFINITY` ou `-INFINITY`
- `isfinite(x)`: diferente de `0` se `x` for um número comum, ou seja, nem `NAN` nem infinito
- `signbit(x)`: diferente de `0` se `x` for negativo, incluindo `-0.0` e `-INFINITY`

```c
double a = sqrt(-1.0);  // nan
double b = 1.0 / 0.0;   // inf
double c = 3.14;

isnan(a);      // verdadeiro
isinf(b);      // verdadeiro
isfinite(c);   // verdadeiro
isfinite(a);   // falso
isfinite(b);   // falso
```

---

**Por que não comparar com NAN**

Toda comparação com `NAN` dá falso, inclusive com ele mesmo, então `x == NAN` nunca é verdadeiro:

```c
double x = sqrt(-1.0);

if (x == NAN) {
  // nunca entra aqui
}

if (isnan(x)) {
  // forma correta
}

x != x; // verdadeiro apenas para NAN, um truque antigo que o isnan substitui
```

---

**NAN se espalha**

Qualquer conta com `NAN` resulta em `NAN`, então um único valor inválido no começo de um cálculo contamina o resultado final:

```c
double soma = 0.0;
double valores[] = {1.0, 2.0, sqrt(-1.0), 4.0};

for (int i = 0; i < 4; i++) {
  soma += valores[i];
}
// soma == nan
```

---

**Validando o resultado de uma conta**

```c
double resultado = log(entrada);

if (!isfinite(resultado)) {
  fprintf(stderr, "resultado inválido para %f\n", entrada);
  return -1;
}
```

---

**fpclassify**

Para tratar cada caso separadamente, o `fpclassify` devolve uma constante indicando a categoria do número:

- `FP_NAN`: é `NAN`
- `FP_INFINITE`: é infinito
- `FP_ZERO`: é `0.0` ou `-0.0`
- `FP_SUBNORMAL`: é tão pequeno que perdeu precisão (abaixo de `DBL_MIN`)
- `FP_NORMAL`: é um número comum

```c
switch (fpclassify(x)) {
  case FP_NAN:      printf("nan\n");      break;
  case FP_INFINITE: printf("infinito\n"); break;
  case FP_ZERO:     printf("zero\n");     break;
  default:          printf("número\n");   break;
}
```

> Diferente de checar o `errno`, que algumas plataformas (como o macOS) não ajustam nas funções da `math.h`, checar o resultado com `isnan` / `isfinite` funciona em qualquer lugar. Essas macros não funcionam com inteiros, que não têm `NAN` nem infinito, e uma divisão inteira por zero não dá `INFINITY`, é comportamento indefinido
