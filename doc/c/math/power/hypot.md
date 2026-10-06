**hypot**

> `math.h`

O `hypot` (de "hipotenusa") calcula `sqrt(x² + y²)`, a hipotenusa de um triângulo retângulo com catetos `x` e `y`, sem estourar nem perder precisão quando os valores são muito grandes ou muito pequenos

> Pelo teorema de Pitágoras, em um triângulo retângulo a hipotenusa `h` satisfaz `h² = x² + y²`. Esse mesmo cálculo dá a distância entre dois pontos e o tamanho (módulo) de um vetor 2D

```c
double hypot(double x, double y);
float hypotf(float x, float y);
long double hypotl(long double x, long double y);
```

- `x` e `y`: os dois catetos, ou as diferenças entre as coordenadas de dois pontos. O sinal não importa

- Devolve `sqrt(x * x + y * y)`
- Se um dos argumentos for infinito, devolve `INFINITY`, mesmo que o outro seja `NAN`

```c
hypot(3.0, 4.0);   // 5.0
hypot(-3.0, 4.0);  // 5.0
hypot(1.0, 1.0);   // 1.4142135623730951
```

**Distância entre dois pontos**

```c
double distancia(double x1, double y1, double x2, double y2) {
  return hypot(x2 - x1, y2 - y1);
}
```

**Por que não só sqrt(x * x + y * y)**

Elevar ao quadrado um número muito grande estoura o `double` antes da raiz trazer o resultado de volta para um tamanho normal:

```c
double x = 1e200;
double y = 1e200;

sqrt(x * x + y * y); // inf, x * x == 1e400 não cabe em um double
hypot(x, y);         // 1.4142135623730951e+200, correto
```

O mesmo acontece com números muito pequenos, cujo quadrado vira `0`:

```c
sqrt(1e-200 * 1e-200 + 1e-200 * 1e-200); // 0
hypot(1e-200, 1e-200);                   // 1.4142135623730951e-200
```

> Diferente do cálculo à mão com `sqrt`, o `hypot` reescala os valores internamente antes de elevar ao quadrado, por isso é a forma segura de calcular distâncias e módulos de vetores. Ele é um pouco mais lento, então em laços com valores pequenos e conhecidos o `sqrt` direto continua sendo uma opção válida
