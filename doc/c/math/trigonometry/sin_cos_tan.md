**sin / cos / tan**

> `math.h`

O `sin`, o `cos` e o `tan` calculam o seno, o cosseno e a tangente de um ângulo, sempre medido em radianos, sendo a base para rotações, movimentos circulares, ondas e qualquer cálculo com ângulos

> Um `radiano` é a unidade de ângulo usada pela matemática e por todas as funções da `math.h`: uma volta completa tem `2π` radianos (`360°`), meia volta tem `π` (`180°`) e um ângulo reto tem `π / 2` (`90°`). Passar graus direto para o `sin` é o erro mais comum com essas funções

```c
double sin(double x);
double cos(double x);
double tan(double x);
```

- `x`: o ângulo em radianos

- `sin` e `cos` devolvem valores entre `-1` e `1`
- `tan` é `sin(x) / cos(x)`, e cresce sem limite perto de `π / 2`, `3π / 2`, etc, onde o cosseno é zero
- Todas existem também com os sufixos `f` e `l` (`sinf`, `cosl`, etc)

**Convertendo graus e radianos**

```c
#define GRAUS_PARA_RAD(g) ((g) * M_PI / 180.0)
#define RAD_PARA_GRAUS(r) ((r) * 180.0 / M_PI)

sin(GRAUS_PARA_RAD(30));   // 0.5
cos(GRAUS_PARA_RAD(60));   // 0.5
tan(GRAUS_PARA_RAD(45));   // 1.0 (aproximadamente)

sin(30);                   // -0.988, 30 radianos, e não 30 graus
```

**Os resultados são aproximados**

`M_PI` não é exatamente π (ele não tem fim), então valores que deveriam ser zero ficam muito próximos de zero, mas não exatamente:

```c
sin(M_PI);       // 1.2246467991473532e-16, e não 0
cos(M_PI / 2);   // 6.123233995736766e-17, e não 0
```

> Por isso o resultado nunca deve ser comparado com `==`. Use uma tolerância, como explicado em `classification/float_compare.md`

**Ponto em um círculo**

A partir de um centro, um raio e um ângulo, o cosseno dá o deslocamento horizontal e o seno o vertical:

```c
double cx = 100.0, cy = 100.0;
double raio = 50.0;
double angulo = GRAUS_PARA_RAD(90);

double x = cx + raio * cos(angulo); // 100.0
double y = cy + raio * sin(angulo); // 150.0
```

**Rotacionando um ponto**

Para girar um ponto `(x, y)` em torno da origem por um ângulo `a`:

```c
double a = GRAUS_PARA_RAD(90);
double x = 1.0, y = 0.0;

double nx = x * cos(a) - y * sin(a); // 0.0 (aproximadamente)
double ny = x * sin(a) + y * cos(a); // 1.0
```

**Movendo na direção de um ângulo**

Em jogos, para mover um objeto "para frente" na direção em que ele está virado:

```c
double velocidade = 5.0;
double direcao = GRAUS_PARA_RAD(45);

pos_x += cos(direcao) * velocidade;
pos_y += sin(direcao) * velocidade;
```

**Onda**

O seno repete o mesmo padrão a cada `2π`, servindo para animações que oscilam e para gerar sinais de áudio:

```c
for (int i = 0; i < 8; i++) {
  double t = i * (2 * M_PI / 8);
  printf("%.2f\n", sin(t));
}
// 0.00  0.71  1.00  0.71  0.00  -0.71  -1.00  -0.71
```

> Diferente das funções inversas (`asin`, `acos`, `atan`), que recebem um valor e devolvem um ângulo, o `sin`, o `cos` e o `tan` recebem um ângulo e devolvem um valor. Em ambos os casos, os ângulos são sempre em radianos
