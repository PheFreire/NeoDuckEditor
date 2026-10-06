**Vector2Normalize**

> `raymath.h`

O `Vector2Normalize` devolve um vetor com a mesma direção, mas com tamanho `1` (vetor unitário). Separa a **direção** de um vetor do seu tamanho

```c
Vector2 Vector2Normalize(Vector2 v);
```

- `v`: o vetor

- Devolve `v / Vector2Length(v)`
- Para o vetor `(0, 0)`, que não tem direção, devolve `(0, 0)` em vez de dividir por zero

```c
// teclado em 8 direções sem andar mais rápido na diagonal
Vector2 dir = { 0 };
if (IsKeyDown(KEY_D)) dir.x += 1;
if (IsKeyDown(KEY_A)) dir.x -= 1;
if (IsKeyDown(KEY_S)) dir.y += 1;
if (IsKeyDown(KEY_W)) dir.y -= 1;

dir = Vector2Normalize(dir);   // (1, 1) vira (0.707, 0.707)
pos = Vector2Add(pos, Vector2Scale(dir, 200 * GetFrameTime()));
```

```text
(1, 1): tamanho √2 ≈ 1,41   → diagonal 41% mais rápida
normalizado (0,707, 0,707): tamanho 1
```

> O caso `(0, 0)` é tratado, então o código acima funciona sem nenhuma tecla apertada. Em outras bibliotecas, normalizar um vetor nulo divide por zero e gera `NAN`
