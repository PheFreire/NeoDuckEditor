**Formatos de pixel**

> `raylib.h` — enum `PixelFormat`

O formato de uma imagem diz como cada pixel é guardado em bytes: quantos canais (cinza, RGB, RGBA), quantos bits por canal e se os dados estão comprimidos. O campo `format` da `Image` (e da `Texture2D`) guarda um valor `PIXELFORMAT_*`

| Formato | Bytes por pixel | Uso |
|---------|-----------------|-----|
| `PIXELFORMAT_UNCOMPRESSED_GRAYSCALE` | 1 | máscaras, mapas de altura |
| `PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA` | 2 | cinza com transparência |
| `PIXELFORMAT_UNCOMPRESSED_R5G6B5` | 2 | cor com menos precisão, sem alfa |
| `PIXELFORMAT_UNCOMPRESSED_R8G8B8` | 3 | cor sem transparência |
| `PIXELFORMAT_UNCOMPRESSED_R8G8B8A8` | 4 | **o mais comum**: cor com transparência (PNG) |
| `PIXELFORMAT_UNCOMPRESSED_R32G32B32A32` | 16 | `float` por canal, para HDR |
| `PIXELFORMAT_COMPRESSED_DXT1_RGB` / `DXT5_RGBA` / `ETC2` / `ASTC`... | 0,25 a 1 | texturas comprimidas para a GPU |

---

**R8G8B8A8 = struct Color**

```text
um pixel R8G8B8A8:   [ R ][ G ][ B ][ A ]   4 bytes
struct Color:        { r,   g,   b,   a }    mesma ordem e tamanho
```

- Por isso, em uma imagem `R8G8B8A8`, o `data` pode ser lido como `Color *` (ver `image-memory.md`)
- `GenImageColor` e `LoadImage` de um PNG com transparência devolvem esse formato

---

**Convertendo**

```c
Image img = LoadImage("foto.png");   // um PNG sem transparência é carregado como R8G8B8 (3 bytes por pixel)

ImageFormat(&img, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);   // agora 4 bytes, com alfa
Color *p = (Color *)img.data;                          // acesso direto seguro
```

- `ImageFormat` converte os dados no lugar, realocando o bloco de pixels
- Alternativa sem mudar a imagem: `Color *p = LoadImageColors(img)` devolve uma **cópia** dos pixels como `Color`, em qualquer formato, que precisa ser liberada com `UnloadImageColors(p)`

---

**Formatos comprimidos**

- `DXT`, `ETC`, `ASTC` e `PVRT` são compressões que a própria GPU entende: a textura ocupa menos memória de vídeo e é descomprimida pelo hardware na hora de desenhar
- Elas não podem ser editadas pixel a pixel pelas funções `Image...`
- São carregadas de arquivos específicos (`.dds`, `.ktx`, `.pkm`, `.astc`), e o suporte depende da GPU

> Na dúvida, trabalhe sempre em `R8G8B8A8`: é o formato que as funções de edição esperam, que o acesso direto pelos `Color` permite e que toda GPU aceita. Os outros formatos servem para economizar memória quando isso realmente importa
