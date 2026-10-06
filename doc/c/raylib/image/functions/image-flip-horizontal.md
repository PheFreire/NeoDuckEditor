**ImageFlipHorizontal**

> `raylib.h` — módulo `rtextures`

O `ImageFlipHorizontal` espelha uma imagem da esquerda para a direita: a primeira coluna de pixels vira a última

```c
void ImageFlipHorizontal(Image *image);
```

- `image`: ponteiro para a imagem (é modificada)

- Não devolve nada
- O tamanho não muda

```c
// gerar a versão "olhando para a esquerda" de um sprite
Image dir = LoadImage("heroi_direita.png");
Image esq = ImageCopy(dir);
ImageFlipHorizontal(&esq);

Texture2D heroi[2] = { LoadTextureFromImage(dir), LoadTextureFromImage(esq) };
UnloadImage(dir);
UnloadImage(esq);
```

> Para espelhar só na hora de desenhar, sem criar uma segunda textura, use o `DrawTextureRec` ou o `DrawTexturePro` com a largura do retângulo de origem negativa: `(Rectangle){ 0, 0, -largura, altura }` desenha a textura espelhada na horizontal
