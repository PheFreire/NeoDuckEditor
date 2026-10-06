**Pixels**

> `raylib.h` — módulo `rshapes`

O `DrawPixel` desenha um único ponto de 1 pixel na tela. É útil para depuração e efeitos simples, mas lento quando usado em grande quantidade, pois cada pixel vira uma pequena geometria enviada à GPU

```c
void DrawPixel(int posX, int posY, Color color);
void DrawPixelV(Vector2 position, Color color);
```

```c
// campo de estrelas
for (int i = 0; i < 200; i++) {
  DrawPixel(estrelas[i].x, estrelas[i].y, WHITE);
}
```

---

**Por que desenhar muitos pixels é lento**

```text
DrawPixel(x, y, cor)
  │  cria um quadrado de 1x1 (2 triângulos, 4 vértices)
  ▼
  │  acumula no buffer de desenho do raylib
  ▼
GPU
```

- Uma tela de 800x450 tem 360 mil pixels. Desenhar cada um com `DrawPixel` gera mais de um milhão de vértices por frame
- Para manipular muitos pixels (efeitos, simulações, emuladores), monte os pixels em memória e envie de uma vez como uma textura:

```c
Color *pixels = malloc(800 * 450 * sizeof(Color));
Image img = { .data = pixels, .width = 800, .height = 450, .mipmaps = 1,
              .format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 };
Texture2D tela = LoadTextureFromImage(img);

while (!WindowShouldClose()) {
  for (int i = 0; i < 800 * 450; i++) {
    pixels[i] = calcular_pixel(i);   // escreve direto na memória da CPU
  }
  UpdateTexture(tela, pixels);       // um único envio para a GPU

  BeginDrawing();
  DrawTexture(tela, 0, 0, WHITE);
  EndDrawing();
}
```

- O `UpdateTexture` copia todo o buffer de uma vez, o que é muito mais rápido que milhares de chamadas de desenho (ver `../texture/functions/update-texture.md`)

> Para desenhar pixels dentro de uma imagem na memória (sem passar pela tela), use o `ImageDrawPixel`, que escreve diretamente nos dados da `Image` (ver `../image/image-drawing.md`)
