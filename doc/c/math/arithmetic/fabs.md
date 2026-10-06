**fabs**

> `math.h`

O `fabs` devolve o valor absoluto de um número de ponto flutuante, ou seja, a distância dele até o zero, sempre positiva, independente do sinal original

> O valor absoluto de `x`, escrito `|x|`, é o próprio `x` se ele for positivo e `-x` se for negativo: `|3.5| = 3.5` e `|-3.5| = 3.5`

```c
double fabs(double x);
float fabsf(float x);
long double fabsl(long double x);
```

- `x`: o número cujo valor absoluto será calculado

- Devolve `x` sem o sinal
- `fabs(-0.0)` devolve `0.0`, `fabs(-INFINITY)` devolve `INFINITY`, e `fabs(NAN)` continua `NAN`
- Nunca gera erro, pois todo número tem valor absoluto

```c
double a = fabs(-3.7);  // 3.7
double b = fabs(2.5);   // 2.5
```

O uso mais comum é medir a distância entre dois valores, sem importar qual é o maior:

```c
double esperado = 10.0;
double medido = 9.7;

double erro = fabs(medido - esperado); // 0.3, mesmo que medido seja menor
```

---

**fabs x abs**

Para inteiros existem funções diferentes, na `stdlib.h`, e misturar os dois é um erro comum:

- `abs(int)`, `labs(long)`, `llabs(long long)`: valor absoluto de inteiros (`stdlib.h`)
- `fabs(double)`: valor absoluto de ponto flutuante (`math.h`)

```c
int i = abs(-5);          // 5

double errado = abs(-2.7); // 2.0, -2.7 é convertido para o int -2 antes do abs
double certo = fabs(-2.7); // 2.7
```

> Diferente do `abs`, que recebe um `int` e corta silenciosamente a parte decimal de um `double` passado para ele, o `fabs` trabalha com o número inteiro. O compilador só avisa sobre esse erro com `-Wall` (no Clang) ou `-Wconversion`, então vale sempre conferir se a função combina com o tipo
