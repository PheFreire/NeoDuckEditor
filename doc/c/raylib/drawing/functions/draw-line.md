**DrawLine**

> `raylib.h` — módulo `rshapes`

O `DrawLine` desenha uma linha reta de 1 pixel de espessura entre dois pontos, dados como coordenadas inteiras

```c
void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color);
```

- `startPosX`, `startPosY`: ponto inicial
- `endPosX`, `endPosY`: ponto final
- `color`: a cor da linha

- Não devolve nada
- A espessura é sempre de 1 pixel (para outras espessuras, use `DrawLineEx`)

```c
// eixos de um gráfico
DrawLine(50, 400, 750, 400, BLACK);   // eixo x
DrawLine(50, 50, 50, 400, BLACK);     // eixo y

// linha de mira do jogador até o mouse
DrawLine((int)jogador.x, (int)jogador.y, GetMouseX(), GetMouseY(), Fade(RED, 0.5f));
```

> Com posições guardadas em `float`, prefira o `DrawLineV`, que recebe `Vector2` e evita os casts para `int` (ver `draw-line-v.md`)
