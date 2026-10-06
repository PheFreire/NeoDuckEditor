**CheckCollisionPointCircle**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionPointCircle` verifica se um ponto está dentro de um círculo. É usado para cliques em objetos redondos, para saber se um alvo está dentro de uma área de alcance e para botões circulares

```c
bool CheckCollisionPointCircle(Vector2 point, Vector2 center, float radius);
```

- `point`: o ponto
- `center`, `radius`: o círculo

- Devolve `true` se a distância do ponto ao centro for menor ou igual ao raio

```c
// torre atira no primeiro inimigo dentro do alcance
for (int i = 0; i < n_inimigos; i++) {
  if (CheckCollisionPointCircle(inimigos[i].pos, torre.pos, torre.alcance)) {
    atirar(torre, i);
    break;
  }
}
```

> Tratar o inimigo como um ponto (o centro dele) é uma simplificação comum para áreas de alcance. Para considerar o tamanho do inimigo, use `CheckCollisionCircles` com o raio dele
