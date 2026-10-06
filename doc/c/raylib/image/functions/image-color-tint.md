**ImageColorTint**

> `raylib.h` — módulo `rtextures`

O `ImageColorTint` aplica uma cor como filtro sobre todos os pixels da imagem: cada canal do pixel é multiplicado pelo canal correspondente da cor

```c
void ImageColorTint(Image *image, Color color);
```

- `image`: ponteiro para a imagem (é modificada)
- `color`: a cor do filtro

- Não devolve nada
- `WHITE` não muda nada, `BLACK` deixa tudo preto (mantendo a transparência)

```text
pixel × cor / 255
(200, 150, 100) × RED (230, 41, 55) / 255 = (180, 24, 21)
```

```c
// variações de cor de um mesmo inimigo
Image base = LoadImage("slime.png");   // desenhado em tons de cinza

Image verde = ImageCopy(base); ImageColorTint(&verde, GREEN);
Image azul  = ImageCopy(base); ImageColorTint(&azul, BLUE);
```

- Imagens desenhadas em tons de cinza funcionam melhor como base, pois o tint colore cada tom proporcionalmente

> O mesmo efeito é aplicado de graça na hora de desenhar, passando a cor como `tint` no `DrawTexture(t, x, y, GREEN)`. Use o `ImageColorTint` só quando a imagem modificada precisa ser salva ou processada depois (ver `../../drawing/colors.md`)
