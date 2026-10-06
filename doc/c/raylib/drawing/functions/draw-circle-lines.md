**DrawCircleLines**

> `raylib.h` — módulo `rshapes`

O `DrawCircleLines` desenha só o contorno de um círculo, com 1 pixel de espessura

```c
void DrawCircleLines(int centerX, int centerY, float radius, Color color);
```

- `centerX`, `centerY`: o centro do círculo
- `radius`: o raio, em pixels
- `color`: a cor do contorno

- Não devolve nada
- Existe também `DrawCircleLinesV(Vector2 center, float radius, Color color)`, com o centro em `Vector2`

```c
// mostrar a área de alcance de uma torre durante a depuração
DrawCircleLines((int)torre.x, (int)torre.y, torre.alcance, Fade(RED, 0.6f));

// mira
DrawCircleLines(GetMouseX(), GetMouseY(), 12, BLACK);
```

> Para um contorno mais grosso, desenhe um anel com `DrawRing`, usando como raio interno o raio menos a espessura e um ângulo de `0` a `360` (ver `../circles.md`)
