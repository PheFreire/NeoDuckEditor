**DrawPolyLines**

> `raylib.h` — módulo `rshapes`

O `DrawPolyLines` desenha só o contorno de um polígono regular, com 1 pixel de espessura

```c
void DrawPolyLines(Vector2 center, int sides, float radius, float rotation, Color color);
```

- `center`: o centro do polígono
- `sides`: a quantidade de lados
- `radius`: a distância do centro até cada vértice
- `rotation`: rotação em graus
- `color`: a cor do contorno

- Não devolve nada
- Para escolher a espessura, use `DrawPolyLinesEx(center, sides, radius, rotation, lineThick, color)`

```c
// seleção de uma célula em um mapa hexagonal
DrawPoly(celula, 6, 30, 30, Fade(YELLOW, 0.3f));
DrawPolyLinesEx(celula, 6, 30, 30, 3, GOLD);
```

> Desenhar o preenchimento com `DrawPoly` e o contorno com `DrawPolyLines` usando os mesmos parâmetros garante que os dois fiquem exatamente alinhados
