**Vector2Subtract**

> `raymath.h`

O `Vector2Subtract` subtrai um vetor de outro. O resultado de `Vector2Subtract(b, a)` é o vetor que vai do ponto `a` até o ponto `b`

```c
Vector2 Vector2Subtract(Vector2 v1, Vector2 v2);
```

- `v1`, `v2`: os vetores

- Devolve `(v1.x - v2.x, v1.y - v2.y)`

```c
Vector2 para_mouse = Vector2Subtract(GetMousePosition(), jogador);   // de jogador até o mouse
float distancia = Vector2Length(para_mouse);
Vector2 direcao = Vector2Normalize(para_mouse);
```

```text
a ●──────────► ● b
   Vector2Subtract(b, a)   = destino - origem
```

> A ordem importa: `Vector2Subtract(a, b)` aponta no sentido contrário de `Vector2Subtract(b, a)`. A regra é "destino menos origem"
