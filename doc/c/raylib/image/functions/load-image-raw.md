**LoadImageRaw**

> `raylib.h` — módulo `rtextures`

O `LoadImageRaw` carrega um arquivo de pixels crus, sem nenhum formato de imagem (sem cabeçalho de PNG ou BMP). Como o arquivo não diz o próprio tamanho nem o formato, o programa precisa informar esses dados

```c
Image LoadImageRaw(const char *fileName, int width, int height, int format, int headerSize);
```

- `fileName`: o arquivo com os bytes dos pixels
- `width`, `height`: o tamanho da imagem
- `format`: o formato dos pixels (`PIXELFORMAT_*`)
- `headerSize`: quantos bytes pular no início do arquivo antes dos pixels (`0` se não houver cabeçalho)

- Devolve a `Image` com os pixels lidos
- Se o arquivo for menor que o tamanho esperado, a imagem fica incompleta ou o carregamento falha com um aviso no log

```c
// mapa de altura de 256x256, 1 byte por pixel, gerado por outra ferramenta
Image altura = LoadImageRaw("terreno.raw", 256, 256, PIXELFORMAT_UNCOMPRESSED_GRAYSCALE, 0);
```

---

**Tamanho esperado**

```text
bytes lidos = headerSize + width x height x bytes_por_pixel

256 x 256 x 1 (GRAYSCALE) = 65.536 bytes
256 x 256 x 4 (R8G8B8A8)  = 262.144 bytes
```

> Formatos crus são usados por ferramentas de terreno, dumps de memória de vídeo e dados científicos. Para imagens comuns, prefira PNG com `LoadImage`, que guarda o tamanho e o formato dentro do próprio arquivo
