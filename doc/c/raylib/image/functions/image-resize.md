**ImageResize**

> `raylib.h` — módulo `rtextures`

O `ImageResize` muda o tamanho de uma imagem usando interpolação bicúbica, que mistura os pixels vizinhos para um resultado suave

```c
void ImageResize(Image *image, int newWidth, int newHeight);
```

- `image`: ponteiro para a imagem (é modificada)
- `newWidth`, `newHeight`: o novo tamanho, em pixels

- Não devolve nada
- A imagem é realocada com o novo tamanho
- Não mantém a proporção automaticamente: para não distorcer, calcule a altura a partir da largura

```c
Image foto = LoadImage("foto.png");

// redimensionar para 300 de largura mantendo a proporção
int nova_altura = foto.height * 300 / foto.width;
ImageResize(&foto, 300, nova_altura);
```

---

**ImageResize vs ImageResizeNN**

| | `ImageResize` | `ImageResizeNN` |
|---|---|---|
| Algoritmo | bicúbico | vizinho mais próximo (nearest neighbor) |
| Resultado | suave, cores misturadas | blocos nítidos, sem cores novas |
| Uso | fotos, ilustrações, reduzir imagens | pixel art, ícones pixelados |

```c
Image sprite = LoadImage("heroi_16x16.png");
ImageResizeNN(&sprite, 64, 64);   // pixel art 4x maior, sem borrar
```

> Para mostrar uma imagem em outro tamanho só na tela, não é preciso redimensionar a imagem: o `DrawTextureEx` (escala) e o `DrawTexturePro` (destino com qualquer tamanho) fazem isso na GPU, e o filtro da textura escolhe entre suave e pixelado (ver `../../texture/texture-filtering.md`)
