**ImageFlipVertical**

> `raylib.h` — módulo `rtextures`

O `ImageFlipVertical` espelha uma imagem de cima para baixo: a primeira linha de pixels vira a última

```c
void ImageFlipVertical(Image *image);
```

- `image`: ponteiro para a imagem (é modificada)

- Não devolve nada
- O tamanho não muda

```text
antes:    ▲        depois:   ▼
         ███                ███
```

```c
// imagem lida de uma render texture vem de cabeça para baixo
Image captura = LoadImageFromTexture(alvo.texture);
ImageFlipVertical(&captura);   // corrige a orientação
ExportImage(captura, "captura.png");
UnloadImage(captura);
```

> O caso mais comum é corrigir imagens vindas do OpenGL: o OpenGL considera a origem das texturas no canto **inferior** esquerdo, enquanto as imagens em arquivo começam pelo canto superior. Por isso o conteúdo de uma render texture aparece invertido na vertical (ver `../../texture/render-texture.md`)
