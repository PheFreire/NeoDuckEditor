**ImageColorGrayscale**

> `raylib.h` — módulo `rtextures`

O `ImageColorGrayscale` converte uma imagem colorida para tons de cinza

```c
void ImageColorGrayscale(Image *image);
```

- `image`: ponteiro para a imagem (é modificada)

- Não devolve nada
- O formato da imagem muda para `PIXELFORMAT_UNCOMPRESSED_GRAYSCALE` (1 byte por pixel). A transparência é perdida: áreas transparentes passam a ser opacas
- O cinza de cada pixel é calculado com pesos diferentes para cada canal, pois o olho humano percebe o verde mais claro que o azul

```text
cinza = 0,299 × R + 0,587 × G + 0,114 × B
```

```c
// ícone desabilitado de um item bloqueado (sobre fundo opaco)
Image icone = LoadImage("espada.png");
Image bloqueado = ImageCopy(icone);
ImageColorGrayscale(&bloqueado);

Texture2D t_normal    = LoadTextureFromImage(icone);
Texture2D t_bloqueado = LoadTextureFromImage(bloqueado);
```

> Para ícones com transparência, um tint cinza na hora de desenhar (`DrawTexture(t, x, y, GRAY)`) ou um shader preservam o alfa. Como o formato muda, o acesso direto aos pixels como `Color *` deixa de ser válido depois da conversão. Para continuar editando como RGBA, converta de volta com `ImageFormat(&img, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)` (ver `../image-format.md`)
