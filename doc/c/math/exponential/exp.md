**exp**

> `math.h`

O `exp` calcula `eˣ`, o número de Euler (`e ≈ 2.71828`) elevado a `x`, a função exponencial usada em crescimento e decaimento contínuos, juros compostos, probabilidade e redes neurais

> O número `e` é a base dos logaritmos naturais e aparece sempre que algo cresce ou diminui a uma taxa proporcional ao próprio tamanho, como uma população ou um investimento com juros contínuos. O `exp` é o inverso do `log`: `log(exp(x)) == x`

```c
double exp(double x);
float expf(float x);
long double expl(long double x);
```

- `x`: o expoente ao qual `e` será elevado

- Devolve `e` elevado a `x`, sempre positivo
- `exp(0)` é `1`, `exp(1)` é `e`, e valores negativos dão resultados entre `0` e `1`
- Cresce muito rápido: com `x` maior que cerca de `709`, o resultado não cabe em um `double` e vira `HUGE_VAL` (`inf`)
- Com `x` muito negativo (menor que cerca de `-745`), o resultado fica pequeno demais e vira `0`

```c
exp(0.0);    // 1.0
exp(1.0);    // 2.718281828459045
exp(2.0);    // 7.38905609893065
exp(-1.0);   // 0.36787944117144233
exp(1000.0); // inf
```

---

**Juros compostos contínuos**

```c
double capital = 1000.0;
double taxa = 0.05;   // 5% ao ano
double anos = 10.0;

double montante = capital * exp(taxa * anos); // 1648.72
```

---

**Decaimento**

Com o expoente negativo, o valor diminui com o tempo, como na meia-vida de um material ou no "esfriamento" de uma animação:

```c
double inicial = 100.0;
double k = 0.3;

for (int t = 0; t <= 3; t++) {
  printf("%.2f\n", inicial * exp(-k * t));
}
// 100.00
// 74.08
// 54.88
// 40.66
```

---

**Sigmoid**

Função muito usada em redes neurais e regressão logística, que transforma qualquer número em um valor entre `0` e `1`:

```c
double sigmoid(double x) {
  return 1.0 / (1.0 + exp(-x));
}

sigmoid(0.0);   // 0.5
sigmoid(5.0);   // 0.9933
sigmoid(-5.0);  // 0.0067
```

---

**Variações**

- `exp2(x)`: calcula `2ˣ`, mais preciso que `pow(2, x)`
- `expm1(x)`: calcula `eˣ - 1` com precisão quando `x` é muito próximo de `0`, onde `exp(x) - 1` perderia quase todos os dígitos

```c
exp2(10.0);        // 1024.0
exp(1e-10) - 1;    // 1.000000082740371e-10, impreciso
expm1(1e-10);      // 1.00000000005e-10, correto
```

> Diferente do `pow`, que aceita qualquer base, o `exp` usa sempre a base `e`, e é mais rápido e preciso para ela. Qualquer potência pode ser escrita com ele (`pow(a, x) == exp(x * log(a))` para `a` positivo), que é inclusive como muitas bibliotecas implementam o `pow` por dentro
