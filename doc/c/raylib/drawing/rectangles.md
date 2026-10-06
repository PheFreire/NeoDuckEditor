**Retângulos**

> `raylib.h` — módulo `rshapes`

O retângulo é a forma mais usada no raylib: fundo de botões, barras de vida, paredes, caixas de colisão e áreas de depuração. Ele pode ser descrito por quatro números ou pela struct `Rectangle`, que também é usada nas funções de colisão e de recorte de texturas

```c
typedef struct Rectangle {
  float x;        // canto superior esquerdo
  float y;
  float width;
  float height;
} Rectangle;
```

| Função | Desenha |
|--------|---------|
| `DrawRectangle(x, y, w, h, cor)` | preenchido, com `int` |
| `DrawRectangleV(pos, tamanho, cor)` | preenchido, com dois `Vector2` |
| `DrawRectangleRec(rec, cor)` | preenchido, a partir de um `Rectangle` |
| `DrawRectanglePro(rec, origem, rotação, cor)` | preenchido e rotacionado |
| `DrawRectangleLines(x, y, w, h, cor)` | contorno de 1 pixel |
| `DrawRectangleLinesEx(rec, espessura, cor)` | contorno com espessura |
| `DrawRectangleRounded(rec, arredondamento, segmentos, cor)` | cantos arredondados |
| `DrawRectangleGradientV` / `GradientH` / `GradientEx` | preenchido com gradiente |

---

**Usando a mesma struct para desenhar e colidir**

```c
Rectangle jogador = { 100, 300, 32, 48 };
Rectangle parede  = { 400, 250, 50, 150 };

jogador.x += vel * GetFrameTime();
bool colidiu = CheckCollisionRecs(jogador, parede);

DrawRectangleRec(parede, GRAY);
DrawRectangleRec(jogador, colidiu ? RED : BLUE);
```

- Guardar a posição e o tamanho em um `Rectangle` evita duplicar dados: o mesmo valor é usado pela lógica (colisão) e pelo desenho

---

**Barra de vida**

```c
void barra_vida(Rectangle area, float vida, float maxima) {
  float fracao = vida / maxima;
  DrawRectangleRec(area, DARKGRAY);                                         // fundo
  DrawRectangle(area.x, area.y, area.width * fracao, area.height,
                ColorLerp(RED, GREEN, fracao));                             // preenchimento
  DrawRectangleLinesEx(area, 2, BLACK);                                     // borda
}
```

> O `DrawRectanglePro` gira o retângulo em torno de um ponto de origem (relativo ao canto superior esquerdo), e não em torno do centro. Para girar no centro, passe a metade do tamanho como origem (ver `functions/draw-rectangle-pro.md`)
