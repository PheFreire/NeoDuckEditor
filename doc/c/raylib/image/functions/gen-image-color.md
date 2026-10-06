**GenImageColor**

> `raylib.h` — módulo `rtextures`

O `GenImageColor` cria uma imagem nova, de um tamanho escolhido, com todos os pixels de uma mesma cor. É o ponto de partida para desenhar imagens do zero com as funções `ImageDraw...`

```c
Image GenImageColor(int width, int height, Color color);
```

- `width`, `height`: o tamanho da imagem, em pixels
- `color`: a cor de todos os pixels

- Devolve uma `Image` no formato `PIXELFORMAT_UNCOMPRESSED_R8G8B8A8`
- Os pixels são alocados na RAM e precisam de `UnloadImage`

```c
Image tela = GenImageColor(320, 180, BLANK);   // transparente
Color *p = (Color *)tela.data;                 // R8G8B8A8: acesso direto como Color

for (int i = 0; i < 320 * 180; i++) {
  if (GetRandomValue(0, 100) < 2) p[i] = WHITE;   // estrelas espalhadas
}

Texture2D ceu = LoadTextureFromImage(tela);
UnloadImage(tela);
```

> Uma imagem transparente (`BLANK`) é útil como "tela" para compor outras imagens com `ImageDraw`, como em atlas de sprites e mapas gerados (ver `../image-drawing.md`)
