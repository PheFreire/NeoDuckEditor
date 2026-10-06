**Editando imagens**

> `raylib.h` — módulo `rtextures`

As funções de manipulação alteram uma `Image` na RAM: recortar, redimensionar, espelhar, girar e mudar as cores. Elas recebem um ponteiro (`Image *`) e modificam a imagem no lugar, normalmente alocando um novo bloco de pixels e liberando o antigo

| Grupo | Funções |
|-------|---------|
| copiar | `ImageCopy`, `ImageFromImage` (um pedaço como imagem nova) |
| tamanho | `ImageCrop`, `ImageResize`, `ImageResizeNN`, `ImageResizeCanvas`, `ImageAlphaCrop` |
| orientação | `ImageFlipVertical`, `ImageFlipHorizontal`, `ImageRotate`, `ImageRotateCW`, `ImageRotateCCW` |
| cor | `ImageColorTint`, `ImageColorInvert`, `ImageColorGrayscale`, `ImageColorContrast`, `ImageColorBrightness`, `ImageColorReplace` |
| transparência | `ImageAlphaClear`, `ImageAlphaMask`, `ImageAlphaPremultiply` |
| efeitos | `ImageBlurGaussian`, `ImageKernelConvolution`, `ImageDither` |
| formato | `ImageFormat`, `ImageToPOT`, `ImageMipmaps` |

```c
Image sprite = LoadImage("heroi.png");

Image esquerda = ImageCopy(sprite);   // cópia independente
ImageFlipHorizontal(&esquerda);       // versão olhando para a esquerda

Image dano = ImageCopy(sprite);
ImageColorTint(&dano, RED);           // versão avermelhada para quando leva dano

Texture2D t_dir  = LoadTextureFromImage(sprite);
Texture2D t_esq  = LoadTextureFromImage(esquerda);
Texture2D t_dano = LoadTextureFromImage(dano);

UnloadImage(sprite);
UnloadImage(esquerda);
UnloadImage(dano);
```

---

**Redimensionar: suave ou pixelado**

```text
original 2x2     ImageResize (bicúbico) 4x4     ImageResizeNN (vizinho mais próximo) 4x4
██  ░░           ██▓▓▒▒░░                       ████░░░░
░░  ██           ▓▓▒▒░░▒▒                       ████░░░░
                 (cores misturadas)              (blocos nítidos)
```

- `ImageResize`: interpolação bicúbica, suave. Bom para fotos e ilustrações
- `ImageResizeNN`: vizinho mais próximo, sem misturar cores. Obrigatório para pixel art, que ficaria borrada com o bicúbico

---

**Na CPU ou na GPU?**

- Editar a `Image` muda os pixels de verdade, uma vez, e o resultado pode ser salvo ou virar textura
- Efeitos que mudam todo frame (piscar, girar continuamente, mudar a cor com o tempo) devem ser feitos na hora de desenhar, com o tint, a rotação do `DrawTextureEx` ou shaders. Editar a imagem e recriar a textura todo frame é muito lento

> Muitas operações exigem o formato `R8G8B8A8` e convertem a imagem para ele automaticamente quando necessário. Para imagens comprimidas (DXT, ETC), a edição não é possível sem antes descomprimir (ver `image-format.md`)
