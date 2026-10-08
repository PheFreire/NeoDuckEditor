**ImageCrop**

> `raylib.h` — módulo `rtextures`

O `ImageCrop` recorta uma imagem, mantendo só a região de um retângulo. A imagem passa a ter o tamanho do recorte

```c
void ImageCrop(Image *image, Rectangle crop);
```

- `image`: ponteiro para a imagem a recortar (é modificada)
- `crop`: a região a manter, em pixels, com `x`, `y` (canto superior esquerdo), `width` e `height`

- Não devolve nada
- A imagem é realocada com o novo tamanho, e os pixels de fora do recorte são descartados
- Se o retângulo passar dos limites da imagem, ele é ajustado para caber

```c
// pegar um sprite de 32x32 de uma folha de sprites
Image folha = LoadImage("personagens.png");
Image heroi = ImageCopy(folha);
ImageCrop(&heroi, (Rectangle){ 64, 0, 32, 32 });   // terceira célula da primeira linha

Texture2D t_heroi = LoadTextureFromImage(heroi);
UnloadImage(heroi);
UnloadImage(folha);
```

---

**ImageCrop vs ImageFromImage**

- `ImageCrop(&img, rec)`: altera a própria imagem, perdendo o resto
- `ImageFromImage(img, rec)`: devolve uma imagem nova com o recorte, mantendo a original. No exemplo acima, substitui o `ImageCopy` + `ImageCrop` (ver `image-from-image.md`)

> Para desenhar só uma parte de uma folha de sprites, não é preciso recortar: carregue a folha inteira como uma textura e desenhe a região desejada com `DrawTextureRec` ou `DrawTexturePro`. Isso usa uma única textura para todos os sprites, o que é mais eficiente (ver `../../texture/texture-drawing.md`)
