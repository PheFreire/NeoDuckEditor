**ImageDraw**

> `raylib.h` — módulo `rtextures`

O `ImageDraw` desenha uma imagem (ou um pedaço dela) dentro de outra, na CPU. É usado para compor imagens: montar um atlas de sprites, colar um ícone sobre um fundo ou gerar um mapa a partir de tiles

```c
void ImageDraw(Image *dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint);
```

- `dst`: ponteiro para a imagem de destino (é modificada)
- `src`: a imagem de origem (não é modificada)
- `srcRec`: o pedaço da origem a copiar
- `dstRec`: onde e com que tamanho colar no destino. Se o tamanho for diferente do `srcRec`, a origem é redimensionada
- `tint`: cor aplicada à origem antes de colar (`WHITE` para não alterar)

- Não devolve nada
- Respeita a transparência da origem: pixels transparentes deixam o destino aparecer

```c
// montar um mapa 10x10 a partir de um tileset de 32x32
Image tileset = LoadImage("tiles.png");
Image mapa = GenImageColor(320, 320, BLANK);

for (int y = 0; y < 10; y++) {
  for (int x = 0; x < 10; x++) {
    int tile = nivel[y][x];
    Rectangle origem  = { (tile % 8) * 32, (tile / 8) * 32, 32, 32 };
    Rectangle destino = { x * 32, y * 32, 32, 32 };
    ImageDraw(&mapa, tileset, origem, destino, WHITE);
  }
}

Texture2D t_mapa = LoadTextureFromImage(mapa);   // o mapa inteiro vira uma única textura
UnloadImage(mapa);
UnloadImage(tileset);
```

> Pré-compor um mapa estático em uma única imagem reduz o desenho a uma chamada por frame, em vez de cem. Para mapas que mudam durante o jogo, uma render texture faz a mesma composição na GPU, muito mais rápido (ver `../../texture/render-texture.md`)
