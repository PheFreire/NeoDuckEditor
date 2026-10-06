**Colisão de retângulos**

> `raylib.h` — módulo `rshapes`

A colisão entre retângulos alinhados aos eixos (AABB) é o teste mais usado em jogos 2D. Dois retângulos colidem quando se sobrepõem tanto no eixo `x` quanto no eixo `y`

```c
bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2);
Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2);
```

- `CheckCollisionRecs`: `true` se os retângulos se sobrepõem
- `GetCollisionRec`: o retângulo da área de sobreposição. Sem sobreposição, devolve um retângulo de tamanho zero

---

**O teste**

```text
eixo x:   a.x < b.x + b.width   e   b.x < a.x + a.width
eixo y:   a.y < b.y + b.height  e   b.y < a.y + a.height

colidem só se os dois eixos se sobrepõem:

  ┌─────┐                ┌─────┐
  │  a  │  ┌─────┐       │  a ┌┼────┐
  └─────┘  │  b  │       └────┼┘ b  │
           └─────┘            └─────┘
sobrepõe em y, não em x     sobrepõe nos dois → colisão
```

- São só quatro comparações, por isso o teste é extremamente rápido

---

**Usando a área de sobreposição**

O `GetCollisionRec` diz o quanto um retângulo entrou no outro, o que ajuda a empurrá-lo de volta pelo menor caminho:

```c
if (CheckCollisionRecs(jogador, parede)) {
  Rectangle sob = GetCollisionRec(jogador, parede);

  if (sob.width < sob.height) {
    // a sobreposição é menor em x: empurrar na horizontal
    if (jogador.x < parede.x) jogador.x -= sob.width;
    else                      jogador.x += sob.width;
  } else {
    // menor em y: empurrar na vertical
    if (jogador.y < parede.y) jogador.y -= sob.height;
    else                      jogador.y += sob.height;
  }
}
```

> Os retângulos não podem estar rotacionados: o teste assume lados paralelos aos eixos. Para formas giradas, uma aproximação comum é usar um círculo como hitbox, que é igual em qualquer rotação (ver `circle-collision.md`)
