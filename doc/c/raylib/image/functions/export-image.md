**ExportImage**

> `raylib.h` — módulo `rtextures`

O `ExportImage` salva uma `Image` em um arquivo no disco. O formato do arquivo é escolhido pela extensão do nome

```c
bool ExportImage(Image image, const char *fileName);
```

- `image`: a imagem a salvar
- `fileName`: o caminho do arquivo, com a extensão que define o formato (`.png`, `.qoi`, ...)

- Devolve `true` se o arquivo foi salvo, e `false` em caso de erro (formato não suportado, pasta inexistente, sem permissão)
- Sobrescreve o arquivo se ele já existir

```c
// screenshot com nome único
Image tela = LoadImageFromScreen();
if (!ExportImage(tela, TextFormat("screenshot_%d.png", (int)time(NULL)))) {
  TraceLog(LOG_WARNING, "não foi possível salvar a screenshot");
}
UnloadImage(tela);
```

---

**Gerando assets**

```c
// gera um atlas de texturas procedurais uma vez e salva para usar depois
Image atlas = GenImageColor(256, 256, BLANK);
for (int i = 0; i < 16; i++) {
  Image tile = GenImagePerlinNoise(64, 64, i * 64, 0, 2.0f);
  ImageDraw(&atlas, tile, (Rectangle){ 0, 0, 64, 64 },
            (Rectangle){ (i % 4) * 64, (i / 4) * 64, 64, 64 }, WHITE);
  UnloadImage(tile);
}
ExportImage(atlas, "atlas.png");
UnloadImage(atlas);
```

> O raylib também tem o `TakeScreenshot("arquivo.png")`, que faz o `LoadImageFromScreen` e o `ExportImage` de uma vez. E o `ExportImageAsCode`, que salva a imagem como um array em um arquivo `.h`, para ser embutida no código e carregada sem arquivo externo
