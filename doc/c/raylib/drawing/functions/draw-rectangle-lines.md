**DrawRectangleLines**

> `raylib.h` — módulo `rshapes`

O `DrawRectangleLines` desenha só o contorno de um retângulo, com 1 pixel de espessura

```c
void DrawRectangleLines(int posX, int posY, int width, int height, Color color);
```

- `posX`, `posY`: o canto superior esquerdo
- `width`, `height`: o tamanho
- `color`: a cor do contorno

- Não devolve nada
- O contorno fica **dentro** da área do retângulo

```c
// mostrar as hitboxes durante a depuração
if (mostrar_hitbox) {
  DrawRectangleLines(jogador.x, jogador.y, jogador.width, jogador.height, GREEN);
  for (int i = 0; i < n_inimigos; i++) {
    Rectangle e = inimigos[i];
    DrawRectangleLines(e.x, e.y, e.width, e.height, RED);
  }
}
```

---

**Contorno com espessura**

```c
void DrawRectangleLinesEx(Rectangle rec, float lineThick, Color color);

DrawRectangleLinesEx((Rectangle){ 100, 100, 200, 80 }, 4, DARKBLUE);   // borda de 4 pixels
```

- A espessura cresce para dentro do retângulo: o tamanho externo continua sendo o do `rec`

> Para cantos arredondados, use o `DrawRectangleRoundedLines` ou o `DrawRectangleRoundedLinesEx`, que recebem o arredondamento de `0.0` (canto reto) a `1.0` (totalmente arredondado) (ver `../rectangles.md`)
