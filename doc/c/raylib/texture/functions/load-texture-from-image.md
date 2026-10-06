**LoadTextureFromImage**

> `raylib.h` — módulo `rtextures`

O `LoadTextureFromImage` cria uma textura na GPU a partir de uma `Image` na RAM, copiando os pixels para a memória de vídeo. É o passo que transforma uma imagem editável em algo que pode ser desenhado

```c
Texture2D LoadTextureFromImage(Image image);
```

- `image`: a imagem de origem

- Devolve a `Texture2D` criada, com o mesmo tamanho, formato e mipmaps da imagem
- A imagem **não** é liberada: continua na RAM e precisa de `UnloadImage` quando não for mais usada
- Precisa da janela criada

```c
Image img = GenImageChecked(256, 256, 32, 32, LIGHTGRAY, GRAY);
ImageDrawText(&img, "TESTE", 80, 110, 30, RED);

Texture2D t = LoadTextureFromImage(img);   // envia para a GPU
UnloadImage(img);                          // a cópia na RAM não é mais necessária
```

---

**Depois do envio, as duas são independentes**

```c
Image img = LoadImage("heroi.png");
Texture2D t = LoadTextureFromImage(img);

ImageColorInvert(&img);   // altera só a imagem na RAM: a textura continua igual
```

- Alterar a imagem depois do `LoadTextureFromImage` não muda a textura. Para atualizar a textura com os pixels novos, use o `UpdateTexture` (ver `update-texture.md`)

> O padrão "carregar ou gerar → editar → `LoadTextureFromImage` → `UnloadImage`" é o fluxo mais comum para texturas que não vêm prontas de um arquivo (ver `../image-vs-texture.md`)
