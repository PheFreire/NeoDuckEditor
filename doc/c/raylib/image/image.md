**image**

> `raylib.h` — módulo `rtextures`

Uma `Image` é uma imagem guardada na **memória RAM (CPU)**: um array de pixels que o programa pode ler e modificar livremente. Imagens não podem ser desenhadas na tela diretamente. Para isso, elas precisam ser enviadas para a GPU como uma `Texture2D`. O módulo de imagem cobre carregar, gerar, editar, desenhar dentro e salvar imagens

```c
typedef struct Image {
  void *data;       // os pixels, na RAM
  int width;        // largura em pixels
  int height;       // altura em pixels
  int mipmaps;      // níveis de mipmap (1 = só a imagem original)
  int format;       // formato dos pixels (PixelFormat)
} Image;
```

```c
Image img = LoadImage("personagem.png");     // arquivo → RAM
ImageResize(&img, 64, 64);                   // edita na CPU
ImageFlipHorizontal(&img);
Texture2D tex = LoadTextureFromImage(img);   // RAM → GPU
UnloadImage(img);                            // a cópia na RAM não é mais necessária

/* desenhar com DrawTexture(tex, ...) */
UnloadTexture(tex);
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| como a imagem fica na memória | `image-memory.md` |
| carregar de arquivo ou da memória | `image-loading.md` |
| gerar imagens (cor sólida, gradiente, ruído) | `image-generation.md` |
| editar (cortar, redimensionar, girar, cores) | `image-manipulation.md` |
| desenhar dentro de uma imagem | `image-drawing.md` |
| formatos de pixel | `image-format.md` |

- Cada função tem sua nota em `functions/`

---

**Image vs Texture**

```text
arquivo .png  ──LoadImage──►  Image (RAM, CPU)  ──LoadTextureFromImage──►  Texture2D (VRAM, GPU)
                                │                                              │
                       ler e editar pixels                               desenhar na tela
                       ImageResize, ImageCrop...                         DrawTexture...
```

- `Image`: editável pelo programa, não desenhável
- `Texture2D`: desenhável e rápida, mas os pixels ficam na GPU e não são acessíveis diretamente
- Ver a comparação completa em `../texture/image-vs-texture.md`
- Ver o caminho inteiro, do arquivo até a tela, em `../concepts/image-to-screen.md`

> As funções `Image...` que modificam a imagem recebem um ponteiro (`Image *`), pois podem trocar os dados, o tamanho e o formato. As que só leem ou criam uma nova recebem a imagem por valor. Toda imagem carregada ou gerada precisa de um `UnloadImage`, que libera os pixels da RAM (ver `functions/unload-image.md`)
