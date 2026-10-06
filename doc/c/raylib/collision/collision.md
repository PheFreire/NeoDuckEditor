**collision**

> `raylib.h` — módulos `rshapes` (2D) e `rmodels` (3D)

As funções de colisão verificam se duas formas geométricas se tocam ou se sobrepõem. Elas não movem nada nem resolvem a colisão: só respondem "sim" ou "não" (ou devolvem onde aconteceu). O que fazer com a resposta, como empurrar o jogador para fora da parede, é decisão do programa

```c
Rectangle jogador = { 100, 100, 32, 32 };
Rectangle parede  = { 200, 80, 20, 200 };
Vector2   moeda   = { 300, 150 };

if (CheckCollisionRecs(jogador, parede)) {
  // desfazer o movimento
}
if (CheckCollisionCircleRec(moeda, 10, jogador)) {
  // coletar a moeda
}
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| como funciona a colisão 2D | `collision-2d.md` |
| ponto dentro de uma forma (cliques, mouse) | `point-collision.md` |
| retângulos (AABB) | `rectangle-collision.md` |
| círculos | `circle-collision.md` |
| linhas e segmentos | `line-collision.md` |
| colisão 3D: esferas, caixas e raios | `collision-3d.md` |

---

**Funções**

| Função | Testa |
|--------|-------|
| `CheckCollisionRecs(a, b)` | retângulo com retângulo |
| `CheckCollisionCircles(c1, r1, c2, r2)` | círculo com círculo |
| `CheckCollisionCircleRec(c, r, rec)` | círculo com retângulo |
| `CheckCollisionPointRec(p, rec)` | ponto dentro de retângulo |
| `CheckCollisionPointCircle(p, c, r)` | ponto dentro de círculo |
| `CheckCollisionPointTriangle(p, a, b, c)` | ponto dentro de triângulo |
| `CheckCollisionLines(a1, a2, b1, b2, &ponto)` | segmento com segmento |
| `GetCollisionRec(a, b)` | a área de sobreposição de dois retângulos |
| `CheckCollisionSpheres(c1, r1, c2, r2)` | esfera com esfera |
| `CheckCollisionBoxes(a, b)` | caixa com caixa (3D) |
| `CheckCollisionBoxSphere(box, c, r)` | caixa com esfera |
| `GetRayCollisionBox(ray, box)` | raio com caixa, com ponto e distância |

---

**Detectar vs resolver**

```text
1. mover          jogador.x += vel.x * dt
2. detectar       CheckCollisionRecs(jogador, parede)?
3. resolver       se colidiu: voltar, empurrar para fora, zerar a velocidade
```

- O raylib faz só o passo 2. A resolução depende do jogo: um personagem para na parede, uma bola quica, um tiro desaparece

> Não existe um "motor de física" no raylib: não há gravidade, massa nem atrito automáticos. Para física completa, bibliotecas como Box2D ou Chipmunk podem ser usadas junto com o raylib para o desenho
