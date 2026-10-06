**ImageColorInvert**

> `raylib.h` — módulo `rtextures`

O `ImageColorInvert` inverte as cores de uma imagem, gerando o "negativo": cada canal de cor vira `255` menos o valor original

```c
void ImageColorInvert(Image *image);
```

- `image`: ponteiro para a imagem (é modificada)

- Não devolve nada
- Inverte os canais vermelho, verde e azul. O alfa (transparência) não muda

```text
(255, 255, 255) branco  →  (0, 0, 0) preto
(230, 41, 55)   vermelho →  (25, 214, 200) ciano
```

```c
// versão "negativa" de um sprite para o efeito de dano
Image heroi = LoadImage("heroi.png");
Image flash = ImageCopy(heroi);
ImageColorInvert(&flash);
Texture2D t_flash = LoadTextureFromImage(flash);
```

> Para inverter cores a cada frame (um flash que pisca), um shader que faz `1.0 - cor.rgb` é mais adequado do que manter uma segunda textura (ver `../../shaders/shaders.md`)
