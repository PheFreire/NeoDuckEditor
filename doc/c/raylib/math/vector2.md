**Vector2**

> `raymath.h` — tipo `Vector2`

Um `Vector2` é um par de `float` (`x`, `y`) que pode representar uma **posição** (um ponto na tela ou no mundo 2D), uma **direção** (para onde algo aponta), uma **velocidade** (quanto se move por segundo) ou um **tamanho**. As funções do raymath fazem as contas com esses vetores

```c
typedef struct Vector2 {
  float x;
  float y;
} Vector2;
```

---

**Operações principais**

| Função | Resultado | Uso |
|--------|-----------|-----|
| `Vector2Add(a, b)` | `(a.x + b.x, a.y + b.y)` | mover: posição + deslocamento |
| `Vector2Subtract(a, b)` | `(a.x - b.x, a.y - b.y)` | vetor de `b` até `a` |
| `Vector2Scale(v, s)` | `(v.x * s, v.y * s)` | aumentar ou diminuir |
| `Vector2Length(v)` | `√(x² + y²)` | tamanho (velocidade escalar, distância) |
| `Vector2Normalize(v)` | `v / tamanho` | só a direção, com tamanho 1 |
| `Vector2Distance(a, b)` | tamanho de `a - b` | distância entre dois pontos |
| `Vector2DotProduct(a, b)` | `a.x * b.x + a.y * b.y` | quão alinhados estão |
| `Vector2Rotate(v, ang)` | `v` girado `ang` radianos | girar direções |
| `Vector2Lerp(a, b, t)` | ponto entre `a` e `b` | movimento suave |
| `Vector2MoveTowards(v, alvo, max)` | anda até `max` em direção ao alvo | perseguir sem passar do alvo |
| `Vector2Angle(a, b)` | ângulo entre dois vetores | mirar |

---

**Posição, direção e velocidade**

```text
          alvo ●
              ╱
             ╱  Vector2Subtract(alvo, pos) = vetor de pos até alvo
            ╱
   pos ●───► Vector2Normalize(...) = só a direção (tamanho 1)
```

```c
// inimigo perseguindo o jogador a velocidade constante
Vector2 para_jogador = Vector2Subtract(jogador, inimigo);
if (Vector2Length(para_jogador) > 1.0f) {
  Vector2 dir = Vector2Normalize(para_jogador);
  inimigo = Vector2Add(inimigo, Vector2Scale(dir, 120 * GetFrameTime()));
}
```

---

**Produto escalar**

```text
dot(a, b) com a e b normalizados:
  1   → mesma direção
  0   → perpendiculares
 -1   → direções opostas
```

```c
// o inimigo está na frente ou atrás do jogador?
Vector2 frente = { cosf(jogador_ang), sinf(jogador_ang) };
Vector2 para_inimigo = Vector2Normalize(Vector2Subtract(inimigo, jogador));
bool na_frente = Vector2DotProduct(frente, para_inimigo) > 0;
```

> Funções terminadas em `Sqr` (`Vector2LengthSqr`, `Vector2DistanceSqr`) devolvem o valor ao quadrado, sem a raiz. Para **comparar** distâncias, elas são mais rápidas: `Vector2DistanceSqr(a, b) < raio * raio` (ver `../../math/power/sqrt.md`)
