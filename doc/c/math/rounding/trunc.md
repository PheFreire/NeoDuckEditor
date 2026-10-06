**trunc**

> `math.h`

O `trunc` remove a parte decimal de um número, sem arredondar, devolvendo apenas a parte inteira dele, ou seja, arredondando sempre em direção ao zero

> Truncar é "cortar" os dígitos depois da vírgula: `2.9` vira `2` e `-2.9` vira `-2`. Para positivos é igual ao `floor`, e para negativos é igual ao `ceil`

```c
double trunc(double x);
float truncf(float x);
long double truncl(long double x);
```

- `x`: o número a ser truncado

- Devolve o resultado como `double`
- Faz o mesmo que um cast para `int`, mas sem converter o tipo, então funciona também com valores grandes demais para caber em um `int`

```c
trunc(2.9);   // 2.0
trunc(2.1);   // 2.0
trunc(-2.9);  // -2.0
trunc(-2.1);  // -2.0
```

**trunc x cast**

```c
double grande = 1e20;

trunc(grande);  // 1e20, continua correto
(int)grande;    // comportamento indefinido, 1e20 não cabe em um int
```

**Comparação com as outras funções de arredondamento**

| x      | `floor` | `ceil` | `round` | `trunc` |
|--------|---------|--------|---------|---------|
| `2.4`  | `2`     | `3`    | `2`     | `2`     |
| `2.5`  | `2`     | `3`    | `3`     | `2`     |
| `2.6`  | `2`     | `3`    | `3`     | `2`     |
| `-2.4` | `-3`    | `-2`   | `-2`    | `-2`    |
| `-2.5` | `-3`    | `-2`   | `-3`    | `-2`    |
| `-2.6` | `-3`    | `-2`   | `-3`    | `-2`    |

**modf**

Quando é preciso a parte inteira e a decimal ao mesmo tempo, o `modf` devolve as duas em uma chamada, ambas com o sinal original:

```c
double modf(double x, double *parte_inteira);

double inteira;
double decimal = modf(-3.75, &inteira); // decimal == -0.75, inteira == -3.0
```

> Diferente do `floor`, que vai sempre para baixo, o `trunc` vai sempre em direção ao zero. Ele é a escolha certa quando se quer "a parte inteira" de um número no sentido literal, como ao separar a parte inteira da decimal, sem que o sinal mude o resultado
