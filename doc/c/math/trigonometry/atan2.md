**atan2**

> `math.h`

O `atan2` calcula o ângulo, em radianos, do vetor que sai da origem e vai até o ponto `(x, y)`, levando em conta o sinal das duas coordenadas para devolver a direção correta em qualquer um dos quatro quadrantes

> O ângulo é medido a partir do eixo `x` positivo (apontando para a direita), crescendo no sentido anti-horário: `0` é direita, `π / 2` é cima, `π` (ou `-π`) é esquerda e `-π / 2` é baixo

```c
double atan2(double y, double x);
float atan2f(float y, float x);
long double atan2l(long double y, long double x);
```

- `y`: a coordenada vertical, que vem primeiro
- `x`: a coordenada horizontal

- Devolve um ângulo entre `-π` e `π` (`-180°` a `180°`)
- Funciona mesmo com `x == 0`, onde `atan(y / x)` dividiria por zero
- `atan2(0, 0)` devolve `0` sem erro

```c
atan2(0.0, 1.0);    // 0.0       (0°, direita)
atan2(1.0, 0.0);    // 1.5707963 (90°, cima)
atan2(1.0, -1.0);   // 2.3561945 (135°)
atan2(-1.0, -1.0);  // -2.3561945 (-135°)
atan2(0.0, -1.0);   // 3.1415926 (180°, esquerda)
```

> A ordem dos argumentos é `(y, x)`, e não `(x, y)`, porque a função calcula a tangente `y / x`. Inverter os dois é um erro comum e devolve o ângulo espelhado

---

**Direção de um ponto até outro**

Em jogos, para fazer um objeto olhar ou atirar na direção de um alvo:

```c
double dx = alvo_x - jogador_x;
double dy = alvo_y - jogador_y;

double angulo = atan2(dy, dx);

// movendo na direção do alvo
pos_x += cos(angulo) * velocidade;
pos_y += sin(angulo) * velocidade;
```

> Em telas, o eixo `y` normalmente cresce para baixo, então o ângulo cresce no sentido horário. A fórmula é a mesma, só a interpretação visual muda

---

**Convertendo para 0° a 360°**

```c
double graus = atan2(-1.0, 0.0) * 180.0 / M_PI; // -90.0

if (graus < 0) {
  graus += 360.0; // 270.0
}
```

---

**Coordenadas polares**

Com o `hypot` para o tamanho e o `atan2` para o ângulo, um ponto `(x, y)` vira `(raio, ângulo)`, e o `cos` / `sin` fazem o caminho de volta:

```c
double x = 3.0, y = 4.0;

double raio = hypot(x, y);     // 5.0
double angulo = atan2(y, x);   // 0.9273 (53.13°)

double x2 = raio * cos(angulo); // 3.0
double y2 = raio * sin(angulo); // 4.0
```

> Diferente do `atan`, que só recebe a divisão `y / x` e devolve ângulos entre `-90°` e `90°`, o `atan2` recebe as duas coordenadas e sabe em qual quadrante o ponto está. Sempre que se tem um `x` e um `y`, o `atan2` é a função certa
