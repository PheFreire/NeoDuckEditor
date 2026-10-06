**DrawCircle**

> `raylib.h` — módulo `rshapes`

O `DrawCircle` desenha um círculo preenchido, posicionado pelo centro, com coordenadas inteiras

```c
void DrawCircle(int centerX, int centerY, float radius, Color color);
```

- `centerX`, `centerY`: o **centro** do círculo
- `radius`: o raio, em pixels
- `color`: a cor de preenchimento

- Não devolve nada
- O círculo é desenhado como um polígono com segmentos suficientes para o raio parecer redondo

```c
DrawCircle(400, 225, 50, RED);   // círculo de 100 pixels de diâmetro no centro de uma janela 800x450

// semáforo
DrawCircle(400, 100, 30, estado == 0 ? RED : DARKGRAY);
DrawCircle(400, 170, 30, estado == 1 ? YELLOW : DARKGRAY);
DrawCircle(400, 240, 30, estado == 2 ? GREEN : DARKGRAY);
```

> A posição é o **centro**, e não o canto, ao contrário do `DrawRectangle`. Para posições em `float`, use o `DrawCircleV` (ver `draw-circle-v.md`)
