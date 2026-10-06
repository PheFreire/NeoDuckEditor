**fmin / fmax**

> `math.h`

O `fmin` e o `fmax` devolvem, respectivamente, o menor e o maior entre dois números de ponto flutuante, tratando corretamente o caso em que um deles é `NAN`

> Comparar dois valores com `<` quando um deles é `NAN` sempre dá falso, então um `a < b ? a : b` escrito à mão pode devolver `NAN` ou não dependendo da ordem dos argumentos. O `fmin` e o `fmax` resolvem isso ignorando o `NAN`

```c
double fmin(double x, double y);
double fmax(double x, double y);
float fminf(float x, float y);
float fmaxf(float x, float y);
```

- `x` e `y`: os dois valores comparados

- `fmin` devolve o menor dos dois, e `fmax` o maior
- Se um dos argumentos for `NAN`, devolve o outro. Só devolve `NAN` se os dois forem
- São funções de verdade, então cada argumento é avaliado uma única vez, ao contrário de uma macro `MIN(a, b)`

```c
double a = fmin(3.5, 2.0);   // 2.0
double b = fmax(3.5, 2.0);   // 3.5
double c = fmax(NAN, 1.0);   // 1.0
double d = fmax(1.0, NAN);   // 1.0, a ordem não importa
```

---

**Limitando um valor a um intervalo (clamp)**

Combinando os dois, é possível prender um valor entre um mínimo e um máximo:

```c
double clamp(double valor, double minimo, double maximo) {
  return fmin(fmax(valor, minimo), maximo);
}

clamp(1.5, 0.0, 1.0);  // 1.0
clamp(-0.2, 0.0, 1.0); // 0.0
clamp(0.7, 0.0, 1.0);  // 0.7
```

> Diferente de uma macro `MAX(a, b)`, que avalia um dos argumentos duas vezes e trata `NAN` de forma diferente conforme a ordem, o `fmin` e o `fmax` são previsíveis. Mas eles só existem para ponto flutuante, então para inteiros continua sendo preciso usar um operador ternário ou uma função própria
