**CheckCollisionBoxSphere**

> `raylib.h` — módulo `rmodels`

O `CheckCollisionBoxSphere` verifica se uma caixa 3D alinhada aos eixos e uma esfera se sobrepõem. É a versão 3D do `CheckCollisionCircleRec`

```c
bool CheckCollisionBoxSphere(BoundingBox box, Vector3 center, float radius);
```

- `box`: a caixa, com os cantos `min` e `max`
- `center`, `radius`: a esfera

- Devolve `true` se a esfera toca ou entra na caixa

```c
// bola contra os blocos de uma fase 3D
for (int i = 0; i < n_blocos; i++) {
  if (CheckCollisionBoxSphere(blocos[i], bola.pos, bola.raio)) {
    bola.vel.y *= -1;
  }
}
```

> O teste calcula a distância da esfera até o ponto da caixa mais próximo do centro dela, a mesma ideia do teste 2D entre círculo e retângulo (ver `../circle-collision.md`)
