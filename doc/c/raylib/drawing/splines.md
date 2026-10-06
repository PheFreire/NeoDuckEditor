**Splines**

> `raylib.h` — módulo `rshapes`

Splines são curvas suaves definidas por uma lista de pontos. O raylib desenha cinco tipos, que diferem em como a curva usa os pontos: passando por todos, aproximando-se deles ou usando alguns como pontos de controle. São usadas para caminhos de inimigos, trilhos, fios, cordas e trajetórias

| Função | Curva | Mínimo de pontos |
|--------|-------|------------------|
| `DrawSplineLinear(pontos, n, espessura, cor)` | segmentos retos ligados | 2 |
| `DrawSplineCatmullRom(pontos, n, espessura, cor)` | passa por todos os pontos | 4 |
| `DrawSplineBasis(pontos, n, espessura, cor)` | B-spline: suave, aproxima sem passar | 4 |
| `DrawSplineBezierQuadratic(pontos, n, espessura, cor)` | Bézier com 1 ponto de controle por trecho | 3 |
| `DrawSplineBezierCubic(pontos, n, espessura, cor)` | Bézier com 2 pontos de controle por trecho | 4 |

```c
Vector2 caminho[] = {
  { 100, 300 }, { 250, 100 }, { 400, 350 }, { 550, 120 }, { 700, 300 },
};
DrawSplineCatmullRom(caminho, 5, 4, BLUE);   // curva passando pelos 5 pontos
```

---

**Os tipos**

```text
pontos:      ●         ●
                 ●         ●
Linear:      ●──────●──────●───   passa por todos, com quinas
CatmullRom:  ●~~~~~~●~~~~~~●~~~   passa por todos, suave
Basis:       ●   ~~~~~~~~~~   ●   suave, mas não passa pelos pontos do meio
Bezier:      ● (início) ... controle puxa a curva ... ● (fim)
```

- **Catmull-Rom**: a escolha mais natural para "uma curva que passa por estes pontos", como o caminho de um inimigo. O primeiro e o último ponto só controlam a direção, e a curva desenhada vai do segundo ao penúltimo
- **Basis (B-spline)**: muito suave, mas os pontos funcionam como ímãs, sem a curva passar por eles
- **Bézier**: pontos de início e fim mais pontos de controle que "puxam" a curva. É o modelo usado em editores vetoriais

---

**Movendo um objeto pela curva**

As funções `GetSplinePoint...` calculam um ponto da curva para um parâmetro `t` de `0` a `1`:

```c
static float t = 0;
t += 0.2f * GetFrameTime();
if (t > 1) t = 0;

// trecho entre caminho[1] e caminho[2] de uma Catmull-Rom
Vector2 pos = GetSplinePointCatmullRom(caminho[0], caminho[1], caminho[2], caminho[3], t);
DrawCircleV(pos, 10, RED);
```

- Cada função de ponto calcula **um trecho** da curva. Para percorrer a curva inteira, avance de trecho em trecho

> Ao contrário de várias chamadas de `DrawLineEx`, as splines tratam as junções entre os segmentos, o que deixa traços grossos contínuos e sem buracos (ver `lines.md`)
