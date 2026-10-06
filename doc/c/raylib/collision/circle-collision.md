**Colisão de círculos**

> `raylib.h` — módulo `rshapes`

Círculos são a forma de colisão mais simples depois do ponto: dois círculos colidem quando a distância entre os centros é menor que a soma dos raios. Como um círculo é igual em qualquer rotação, ele é uma ótima hitbox para objetos que giram

```c
bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2);
bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec);
bool CheckCollisionCircleLine(Vector2 center, float radius, Vector2 p1, Vector2 p2);
```

---

**Círculo com círculo**

```text
       r1         r2
   ●───────●  ●───────●
   c1         c2
   |←── distância ──→|

colidem se: distância(c1, c2) <= r1 + r2
```

- O raylib compara os quadrados (`dx² + dy² <= (r1 + r2)²`), evitando a raiz quadrada

```c
for (int i = 0; i < n_asteroides; i++) {
  if (CheckCollisionCircles(nave.pos, nave.raio, ast[i].pos, ast[i].raio)) {
    perder_vida();
  }
}
```

---

**Círculo com retângulo**

```text
         ┌──────────┐
         │          │
         │       ●──┼──●  centro do círculo
         │  ponto mais próximo
         └──────────┘
```

- O teste encontra o ponto do retângulo mais próximo do centro do círculo (limitando o centro aos limites do retângulo) e verifica se esse ponto está dentro do raio
- Usado para uma bola contra paddles e paredes, ou um personagem redondo contra blocos

---

**Quicando**

```c
// bola quicando nas paredes da tela
if (bola.x - raio < 0 || bola.x + raio > GetScreenWidth())  vel.x *= -1;
if (bola.y - raio < 0 || bola.y + raio > GetScreenHeight()) vel.y *= -1;

// bola contra o paddle
if (CheckCollisionCircleRec(bola, raio, paddle) && vel.y > 0) {
  vel.y *= -1;   // só inverte se estiver descendo, para não "grudar" no paddle
}
```

> Inverter a velocidade sem conferir a direção faz a bola ficar presa: se ela continuar sobreposta no frame seguinte, a velocidade é invertida de novo, e ela vibra dentro do objeto. Verifique o sinal da velocidade ou empurre a bola para fora antes de inverter
