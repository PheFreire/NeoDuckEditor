**log**

> `math.h`

O `log` calcula o logaritmo natural de um número, ou seja, a qual potência é preciso elevar `e` (`≈ 2.71828`) para chegar nele, e a `math.h` traz também as versões nas bases `10` (`log10`) e `2` (`log2`)

> O logaritmo responde "quantas vezes é preciso multiplicar a base por ela mesma para chegar a `x`": `log10(1000)` é `3`, pois `10 * 10 * 10 == 1000`. É o inverso da potência, e transforma multiplicações em somas: `log(a * b) == log(a) + log(b)`

```c
double log(double x);    // base e (logaritmo natural, ln)
double log10(double x);  // base 10
double log2(double x);   // base 2
double log1p(double x);  // log(1 + x), preciso para x perto de 0
```

- `x`: o número cujo logaritmo será calculado, que precisa ser positivo

- Devolve o expoente correspondente na base da função
- `log(1)` é `0` em qualquer base, pois qualquer número elevado a `0` dá `1`
- `log(0)` devolve `-INFINITY` (erro de polo)
- O logaritmo de um número negativo não existe nos reais e devolve `NAN` (erro de domínio)
- Todas existem também com os sufixos `f` e `l` (`logf`, `log10l`, etc)

```c
log(M_E);      // 1.0
log(1.0);      // 0.0
log10(1000.0); // 3.0
log2(1024.0);  // 10.0
log(0.0);      // -inf
log(-1.0);     // nan
```

**Logaritmo em qualquer base**

Não existe uma função para bases arbitrárias, mas qualquer logaritmo pode ser obtido dividindo dois logaritmos da mesma base:

```c
double log_base(double x, double base) {
  return log(x) / log(base);
}

log_base(81.0, 3.0); // 4.0, pois 3^4 == 81
```

**Quantidade de dígitos de um número**

```c
int digitos(int n) {
  if (n == 0) {
    return 1;
  }
  return (int)log10(abs(n)) + 1;
}

digitos(7);      // 1
digitos(12345);  // 5
```

**Quantos bits são necessários**

```c
unsigned int valores = 1000;
int bits = (int)ceil(log2(valores)); // 10, pois 2^10 == 1024 >= 1000
```

**Escala logarítmica**

Usada para comparar valores de tamanhos muito diferentes, como decibéis, a escala Richter ou o pH:

```c
double potencia = 0.001;
double referencia = 1.0;
double decibeis = 10.0 * log10(potencia / referencia); // -30.0
```

> Diferente do `exp`, que cresce muito rápido, o `log` cresce muito devagar, e cada um desfaz o outro (`exp(log(x)) == x`). O `log` sem sufixo de base é o natural (`ln`), e não o de base 10 como em calculadoras, um erro comum ao traduzir fórmulas
