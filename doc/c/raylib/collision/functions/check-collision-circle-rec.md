**CheckCollisionCircleRec**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionCircleRec` verifica se um círculo e um retângulo alinhado aos eixos se sobrepõem. É o teste usado em jogos como Breakout e Pong, com a bola redonda contra blocos e raquetes retangulares

```c
bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec);
```

- `center`, `radius`: o círculo
- `rec`: o retângulo

- Devolve `true` se o círculo toca ou entra no retângulo

```c
// Breakout: bola contra os blocos
for (int i = 0; i < n_blocos; i++) {
  if (blocos[i].ativo && CheckCollisionCircleRec(bola.pos, bola.raio, blocos[i].rec)) {
    blocos[i].ativo = false;
    bola.vel.y *= -1;
    break;   // quebra um bloco por frame
  }
}
```

---

**A ideia do teste**

```text
o ponto do retângulo mais próximo do centro do círculo:

  ┌───────────┐
  │           │
  │           ●←─────● centro
  │    rec    │  distância <= raio? → colisão
  └───────────┘
```

- O teste é equivalente a encontrar o ponto do retângulo mais próximo do centro e verificar se ele está dentro do raio
- Funciona tanto para o círculo encostando em um lado quanto em um canto

> O teste diz se colidiram, mas não de qual lado. Para saber se a bola deve quicar na horizontal ou na vertical, compare a posição do centro com os lados do retângulo, ou use o `GetCollisionRec` com o retângulo que envolve a bola
