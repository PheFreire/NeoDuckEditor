**Imagem na memória**

> `raylib.h` — tipo `Image`

Uma `Image` é uma struct pequena que aponta para um bloco de memória com os pixels. A struct guarda as informações (largura, altura, formato), e o ponteiro `data` aponta para os bytes, alocados com `malloc` pelo raylib

```text
Image (struct, na pilha ou onde for declarada)
┌─────────────────────────┐
│ data   ─────────────────┼──►  heap: [R G B A][R G B A][R G B A] ...  (width x height pixels)
│ width  = 3              │
│ height = 2              │
│ mipmaps = 1             │
│ format = R8G8B8A8       │
└─────────────────────────┘
```

---

**Como os pixels ficam organizados**

```text
imagem 3x2:         memória (linha por linha, de cima para baixo):

(0,0) (1,0) (2,0)   [ (0,0) | (1,0) | (2,0) | (0,1) | (1,1) | (2,1) ]
(0,1) (1,1) (2,1)     índice 0   1       2       3       4       5

índice = y * width + x
```

- No formato `PIXELFORMAT_UNCOMPRESSED_R8G8B8A8` (o mais comum), cada pixel ocupa 4 bytes, na mesma ordem da struct `Color`. Por isso `data` pode ser tratado como um array de `Color`:

```c
Image img = GenImageColor(256, 256, BLACK);
Color *pixels = (Color *)img.data;

for (int y = 0; y < img.height; y++) {
  for (int x = 0; x < img.width; x++) {
    pixels[y * img.width + x] = (Color){ x, y, 128, 255 };   // gradiente
  }
}
```

- Esse acesso direto só é válido se o formato for `R8G8B8A8`. Para outros formatos, converta antes com `ImageFormat` ou use `LoadImageColors` (ver `image-format.md`)

---

**Tamanho na memória**

```text
1920 x 1080 x 4 bytes (RGBA) = 8.294.400 bytes ≈ 7,9 MB
```

- Uma imagem grande ocupa bastante RAM. Libere com `UnloadImage` assim que ela não for mais necessária, normalmente logo depois de criar a textura

---

**Cópia rasa: a armadilha da struct**

```c
Image a = LoadImage("foto.png");
Image b = a;          // copia só a struct: b.data e a.data apontam para os MESMOS pixels

ImageFlipVertical(&b);   // o flip realoca b.data e libera o bloco antigo, que a.data ainda aponta
UnloadImage(a);          // a.data já foi liberado: double free ou corrupção de memória
```

- Atribuir uma `Image` a outra copia o ponteiro, e não os pixels. As duas passam a dividir a mesma memória
- Para uma cópia independente, use `ImageCopy`, que aloca um bloco novo (ver `functions/image-copy.md`)

> Muitas funções `Image...` alocam um novo bloco de pixels, liberam o antigo e atualizam o `data` da imagem passada pelo ponteiro. Por isso, guardar o ponteiro `img.data` em outra variável antes de uma operação como `ImageResize` resulta em um ponteiro inválido depois dela
