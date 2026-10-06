**DrawCircleV**

> `raylib.h` — módulo `rshapes`

O `DrawCircleV` desenha um círculo preenchido com o centro dado como `Vector2`. É a versão mais usada em jogos, onde as posições são guardadas em `float`

```c
void DrawCircleV(Vector2 center, float radius, Color color);
```

- `center`: o centro do círculo
- `radius`: o raio, em pixels
- `color`: a cor de preenchimento

- Não devolve nada

```c
typedef struct {
  Vector2 pos;
  Vector2 vel;
  float raio;
} Bola;

Bola b = { { 400, 225 }, { 200, 150 }, 15 };

b.pos = Vector2Add(b.pos, Vector2Scale(b.vel, GetFrameTime()));
if (b.pos.x < b.raio || b.pos.x > GetScreenWidth()  - b.raio) b.vel.x *= -1;   // quica nas bordas
if (b.pos.y < b.raio || b.pos.y > GetScreenHeight() - b.raio) b.vel.y *= -1;

DrawCircleV(b.pos, b.raio, MAROON);
```

> Desenhar com `Vector2` evita o arredondamento para `int` a cada frame, o que deixa objetos lentos se movendo de forma suave, em vez de "pular" de um pixel para o próximo
