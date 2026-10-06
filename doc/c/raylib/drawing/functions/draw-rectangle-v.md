**DrawRectangleV**

> `raylib.h` — módulo `rshapes`

O `DrawRectangleV` desenha um retângulo preenchido com a posição e o tamanho dados como `Vector2`

```c
void DrawRectangleV(Vector2 position, Vector2 size, Color color);
```

- `position`: o canto superior esquerdo
- `size`: a largura em `size.x` e a altura em `size.y`
- `color`: a cor de preenchimento

- Não devolve nada

```c
Vector2 pos = { 100.5f, 200.25f };
Vector2 tamanho = { 32, 48 };

pos.x += 120 * GetFrameTime();   // movimento em float, sem arredondar
DrawRectangleV(pos, tamanho, BLUE);
```

> Na maioria dos jogos, guardar posição e tamanho juntos em um `Rectangle` é mais prático, pois a mesma variável serve para o `DrawRectangleRec` e para as funções de colisão (ver `draw-rectangle-rec.md`)
