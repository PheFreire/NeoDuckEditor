**ImageDrawPixel**

> `raylib.h` — módulo `rtextures`

O `ImageDrawPixel` muda a cor de um único pixel dentro de uma imagem na RAM

```c
void ImageDrawPixel(Image *dst, int posX, int posY, Color color);
```

- `dst`: ponteiro para a imagem (é modificada)
- `posX`, `posY`: a posição do pixel na imagem
- `color`: a nova cor

- Não devolve nada
- Posições fora da imagem são ignoradas
- Existe também `ImageDrawPixelV(Image *dst, Vector2 position, Color color)`

```c
// gráfico de uma função desenhado em uma imagem
Image grafico = GenImageColor(400, 200, RAYWHITE);
for (int x = 0; x < 400; x++) {
  int y = 100 - (int)(sinf(x * 0.05f) * 80);
  ImageDrawPixel(&grafico, x, y, RED);
}
ExportImage(grafico, "seno.png");
UnloadImage(grafico);
```

---

**Acesso direto**

Para alterar muitos pixels, escrever direto no array é mais rápido que chamar a função para cada um:

```c
Image img = GenImageColor(256, 256, BLACK);   // R8G8B8A8
Color *p = (Color *)img.data;
p[y * img.width + x] = RED;                    // o mesmo que ImageDrawPixel(&img, x, y, RED)
```

- O acesso direto só funciona se o formato for `R8G8B8A8`, e não confere os limites da imagem (ver `../image-memory.md`)

> O `ImageDrawPixel` converte a cor para o formato da imagem, qualquer que seja ele. É mais lento que o acesso direto, mas funciona com imagens em tons de cinza ou em formatos de 16 bits sem nenhuma conversão manual
