**DrawRectangle**

> `raylib.h` — módulo `rshapes`

O `DrawRectangle` desenha um retângulo preenchido, definido pelo canto superior esquerdo, a largura e a altura, com valores inteiros

```c
void DrawRectangle(int posX, int posY, int width, int height, Color color);
```

- `posX`, `posY`: o canto **superior esquerdo**
- `width`: a largura, em pixels
- `height`: a altura, em pixels
- `color`: a cor de preenchimento

- Não devolve nada

```c
DrawRectangle(0, 0, GetScreenWidth(), 40, DARKGRAY);   // barra superior
DrawRectangle(10, 10, 200, 20, RED);                   // barra de vida

// escurecer a tela inteira atrás de um menu de pausa
DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(BLACK, 0.6f));
```

---

**Variações**

| Função | Diferença |
|--------|-----------|
| `DrawRectangleV(pos, tamanho, cor)` | posição e tamanho em `Vector2` |
| `DrawRectangleRec(rec, cor)` | um `Rectangle` |
| `DrawRectanglePro(rec, origem, rotação, cor)` | com rotação |
| `DrawRectangleLines(...)` | só o contorno |

> A posição é o canto, e não o centro. Para centralizar em um ponto, subtraia metade do tamanho: `DrawRectangle(cx - w / 2, cy - h / 2, w, h, cor)` (ver `../coordinates.md`)
