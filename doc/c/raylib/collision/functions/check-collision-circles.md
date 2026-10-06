**CheckCollisionCircles**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionCircles` verifica se dois círculos se sobrepõem, comparando a distância entre os centros com a soma dos raios

```c
bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2);
```

- `center1`, `radius1`: o primeiro círculo
- `center2`, `radius2`: o segundo círculo

- Devolve `true` se a distância entre os centros for menor ou igual à soma dos raios

```c
// asteroides
for (int i = 0; i < n; i++) {
  for (int j = i + 1; j < n; j++) {
    if (CheckCollisionCircles(ast[i].pos, ast[i].raio, ast[j].pos, ast[j].raio)) {
      quebrar(i, j);
    }
  }
}
```

- O laço com `j = i + 1` testa cada par uma única vez, sem testar um objeto com ele mesmo

---

**Por dentro**

```c
float dx = center2.x - center1.x;
float dy = center2.y - center1.y;
bool colidem = dx * dx + dy * dy <= (radius1 + radius2) * (radius1 + radius2);
```

- Comparar os quadrados evita o `sqrtf`, deixando o teste mais rápido

> Círculos são boas hitboxes para objetos que giram, como naves e asteroides: um retângulo precisaria ser recalculado a cada rotação, e o círculo é o mesmo em qualquer ângulo (ver `../circle-collision.md`)
