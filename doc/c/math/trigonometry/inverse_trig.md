**asin / acos / atan**

> `math.h`

O `asin`, o `acos` e o `atan` são as funções trigonométricas inversas: recebem o valor de um seno, cosseno ou tangente e devolvem o ângulo, em radianos, que produz esse valor

> Se `sin(a) == v`, então `asin(v) == a`. Como o seno se repete a cada volta, infinitos ângulos têm o mesmo seno, e as funções inversas devolvem sempre o ângulo dentro de um intervalo fixo (o "valor principal")

```c
double asin(double x);
double acos(double x);
double atan(double x);
```

- `x`: o valor do seno (`asin`), cosseno (`acos`) ou tangente (`atan`)

- `asin(x)`: aceita `x` entre `-1` e `1`, devolve um ângulo entre `-π / 2` e `π / 2` (`-90°` a `90°`)
- `acos(x)`: aceita `x` entre `-1` e `1`, devolve um ângulo entre `0` e `π` (`0°` a `180°`)
- `atan(x)`: aceita qualquer `x`, devolve um ângulo entre `-π / 2` e `π / 2`
- Fora de `-1` a `1`, `asin` e `acos` devolvem `NAN`, pois nenhum ângulo tem seno ou cosseno maior que `1`
- Todas existem também com os sufixos `f` e `l`

```c
asin(0.5);   // 0.5235987755982989 (30°)
acos(0.5);   // 1.0471975511965976 (60°)
atan(1.0);   // 0.7853981633974483 (45°)
acos(-1.0);  // 3.141592653589793  (180°, π)
asin(1.5);   // nan
```

Para ver o resultado em graus:

```c
double graus = asin(0.5) * 180.0 / M_PI; // 30.0
```

**Ângulo entre dois vetores**

O cosseno do ângulo entre dois vetores é o produto escalar dividido pelo produto dos tamanhos, então o `acos` devolve o ângulo:

```c
double ax = 1.0, ay = 0.0;
double bx = 1.0, by = 1.0;

double dot = ax * bx + ay * by;
double cosseno = dot / (hypot(ax, ay) * hypot(bx, by));

// erros de arredondamento podem deixar o valor em 1.0000000002, o que daria NAN
cosseno = fmax(-1.0, fmin(1.0, cosseno));

double angulo = acos(cosseno) * 180.0 / M_PI; // 45.0
```

**Por que o atan sozinho não basta**

O `atan` recebe só a divisão `y / x`, então perde a informação de qual quadrante o ponto está: `(1, 1)` e `(-1, -1)` têm a mesma divisão (`1`), mas estão em direções opostas

```c
atan(1.0 / 1.0);     // 0.785  (45°)
atan(-1.0 / -1.0);   // 0.785  (45°), mas o ponto (-1, -1) está a -135°
```

> Diferente do `atan`, o `atan2` recebe `y` e `x` separados e devolve o ângulo correto em qualquer quadrante, de `-π` a `π`. Para descobrir a direção de um ponto ou de um vetor, use sempre o `atan2`, explicado em `atan2.md`
