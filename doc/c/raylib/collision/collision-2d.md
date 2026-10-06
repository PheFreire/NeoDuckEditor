**Colisão 2D**

> `raylib.h` — módulo `rshapes`

Em jogos 2D, os objetos raramente colidem usando o seu formato exato (o desenho do sprite). Cada objeto recebe uma **forma de colisão** simples (hitbox), normalmente um retângulo ou um círculo, e são essas formas que são testadas. São muito mais baratas de testar e quase sempre suficientes

```text
sprite do personagem          hitbox (retângulo)
     ▲                         ┌──────┐
    ███                        │      │
   █████          →            │      │
    █ █                        └──────┘
```

---

**Escolhendo a forma**

| Forma | Bom para | Teste |
|-------|----------|-------|
| retângulo alinhado (AABB) | personagens, plataformas, paredes, tiles | 4 comparações |
| círculo | bolas, moedas, explosões, áreas de alcance | distância entre centros |
| ponto | cliques, cursor, projéteis muito pequenos | dentro ou fora |
| segmento | raios laser, linhas de visão, bordas | interseção de retas |
| triângulo / polígono | terreno inclinado, formas irregulares | mais caro |

- AABB (axis-aligned bounding box): retângulo com os lados paralelos aos eixos, sem rotação. É o tipo da struct `Rectangle`
- As funções do raylib não consideram rotação. Um retângulo girado precisa de outra abordagem (vários círculos, polígono, ou a biblioteca de física)

---

**Colisão a cada frame**

```c
Rectangle jogador = { 100, 300, 32, 48 };
Vector2 vel = { 0 };

// 1. mover em x e resolver em x
jogador.x += vel.x * dt;
for (int i = 0; i < n_paredes; i++) {
  if (CheckCollisionRecs(jogador, paredes[i])) {
    if (vel.x > 0) jogador.x = paredes[i].x - jogador.width;      // bateu pela esquerda
    else           jogador.x = paredes[i].x + paredes[i].width;   // bateu pela direita
    vel.x = 0;
  }
}

// 2. mover em y e resolver em y
jogador.y += vel.y * dt;
for (int i = 0; i < n_paredes; i++) {
  if (CheckCollisionRecs(jogador, paredes[i])) {
    if (vel.y > 0) { jogador.y = paredes[i].y - jogador.height; no_chao = true; }
    else           jogador.y = paredes[i].y + paredes[i].height;
    vel.y = 0;
  }
}
```

- Resolver cada eixo separadamente evita ambiguidade: sabendo em qual eixo o movimento causou a colisão, o lado da batida é óbvio
- Essa técnica é a base de quase todo jogo de plataforma 2D

---

**Tunneling: atravessar paredes**

```text
frame 1:  ●        │parede│
frame 2:           │parede│        ●     a bola pulou a parede inteira em um frame
```

- Se um objeto se move mais que a espessura da parede em um único frame, ele nunca está "dentro" dela, e a colisão nunca é detectada
- Soluções: limitar a velocidade máxima, limitar o delta time (ver `../concepts/delta-time.md`), dividir o movimento em passos menores, ou testar o segmento percorrido com `CheckCollisionLines`

> Antes de testar todos os objetos contra todos (`n²` testes), jogos com muitos objetos dividem o mapa em uma grade e só testam objetos na mesma célula. Para algumas dezenas de objetos, o teste direto é rápido o suficiente
