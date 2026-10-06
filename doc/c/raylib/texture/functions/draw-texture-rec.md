**DrawTextureRec**

> `raylib.h` — módulo `rtextures`

O `DrawTextureRec` desenha só um pedaço retangular de uma textura, no tamanho original. É a função básica para spritesheets e tilesets: uma imagem com vários sprites, dos quais só um é desenhado de cada vez

```c
void DrawTextureRec(Texture2D texture, Rectangle source, Vector2 position, Color tint);
```

- `texture`: a textura (spritesheet, tileset)
- `source`: o pedaço da textura a desenhar, em pixels da textura
- `position`: onde desenhar o canto superior esquerdo do pedaço
- `tint`: cor que multiplica os pixels

- Não devolve nada
- Largura negativa no `source` espelha na horizontal, altura negativa espelha na vertical

```c
// tileset com tiles de 16x16, 8 por linha
void desenhar_tile(Texture2D tileset, int tile, int x, int y) {
  Rectangle src = { (tile % 8) * 16, (tile / 8) * 16, 16, 16 };
  DrawTextureRec(tileset, src, (Vector2){ x * 16, y * 16 }, WHITE);
}

for (int y = 0; y < ALTURA; y++)
  for (int x = 0; x < LARGURA; x++)
    desenhar_tile(tileset, mapa[y][x], x, y);
```

---

**Animação e espelhamento**

```c
Rectangle frame = { quadro * 32, 0, 32, 32 };
if (olhando_esquerda) frame.width = -frame.width;   // mesmo frame, espelhado
DrawTextureRec(folha, frame, pos, WHITE);
```

> Para desenhar o pedaço em outro tamanho ou com rotação, use o `DrawTexturePro`, que recebe o `source` e também o retângulo de destino (ver `draw-texture-pro.md`)
