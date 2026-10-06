**ImageDrawLine**

> `raylib.h` — módulo `rtextures`

O `ImageDrawLine` desenha uma linha reta de 1 pixel dentro de uma imagem na RAM

```c
void ImageDrawLine(Image *dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color);
```

- `dst`: ponteiro para a imagem (é modificada)
- `startPosX`, `startPosY`: o ponto inicial
- `endPosX`, `endPosY`: o ponto final
- `color`: a cor da linha

- Não devolve nada
- As partes da linha fora da imagem são ignoradas
- Versões: `ImageDrawLineV` (com `Vector2`) e `ImageDrawLineEx` (com espessura)

```c
// grade sobre uma imagem de mapa
Image mapa = LoadImage("mapa.png");
for (int x = 0; x < mapa.width; x += 32) {
  ImageDrawLine(&mapa, x, 0, x, mapa.height - 1, Fade(BLACK, 0.3f));
}
for (int y = 0; y < mapa.height; y += 32) {
  ImageDrawLine(&mapa, 0, y, mapa.width - 1, y, Fade(BLACK, 0.3f));
}
ExportImage(mapa, "mapa_com_grade.png");
```

> As linhas são desenhadas pixel a pixel pela CPU, sem antialiasing. Para linhas suaves, desenhe na tela com `DrawLineEx` ou em uma render texture com as funções `Draw...` normais (ver `../image-drawing.md`)
