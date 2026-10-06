**drawing**

> `raylib.h` — módulos `rcore` e `rshapes`

O desenho no raylib é feito por funções `Draw...` chamadas dentro de um bloco `BeginDrawing` / `EndDrawing`. Este módulo cobre o ciclo de desenho de um frame e as formas 2D básicas: pixels, linhas, retângulos, círculos, triângulos, polígonos e curvas, além do recorte de área com scissor mode

```c
BeginDrawing();
ClearBackground(RAYWHITE);

DrawRectangle(50, 50, 200, 100, SKYBLUE);           // preenchido
DrawRectangleLines(50, 50, 200, 100, DARKBLUE);     // contorno
DrawCircle(400, 100, 50, RED);
DrawLine(50, 300, 750, 300, GRAY);
DrawTriangle((Vector2){ 600, 400 }, (Vector2){ 700, 400 }, (Vector2){ 650, 320 }, GREEN);

EndDrawing();
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| o ciclo de um frame: `BeginDrawing`, `ClearBackground`, `EndDrawing` | `drawing-cycle.md` |
| sistema de coordenadas da tela | `coordinates.md` |
| cores, transparência, `Fade`, `ColorFromHSV` | `colors.md` |
| pixels | `pixels.md` |
| linhas | `lines.md` |
| retângulos | `rectangles.md` |
| círculos e elipses | `circles.md` |
| triângulos | `triangles.md` |
| polígonos regulares | `polygons.md` |
| curvas (splines) | `splines.md` |
| recortar a área de desenho | `scissor-mode.md` |

- Cada função tem sua nota em `functions/`

---

**Ordem de desenho**

```text
DrawRectangle(...)   desenhado primeiro  → fica atrás
DrawCircle(...)
DrawText(...)        desenhado por último → fica na frente
```

- Em 2D, não há profundidade: o que é desenhado depois aparece por cima do que foi desenhado antes (algoritmo do pintor)
- Para controlar o que fica na frente, ordene as chamadas: fundo, cenário, personagens, efeitos, interface

---

**Preenchido vs contorno**

- Funções sem sufixo desenham a forma preenchida: `DrawRectangle`, `DrawCircle`, `DrawTriangle`
- Funções com `Lines` desenham só o contorno: `DrawRectangleLines`, `DrawCircleLines`, `DrawTriangleLines`
- Versões `LinesEx` permitem escolher a espessura do contorno: `DrawRectangleLinesEx`, `DrawPolyLinesEx`

> As formas do `rshapes` são desenhadas com triângulos na GPU, usando uma textura branca de 1 pixel e a cor como tinta. Por isso, desenhar milhares de formas por frame é rápido: o raylib agrupa os triângulos em poucos envios para a GPU (ver `../concepts/rendering-pipeline.md`)
