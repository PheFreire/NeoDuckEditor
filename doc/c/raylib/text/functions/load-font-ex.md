**LoadFontEx**

> `raylib.h` — módulo `rtext`

O `LoadFontEx` carrega uma fonte de um arquivo escolhendo o tamanho em que os caracteres são rasterizados e quais caracteres incluir. É a forma recomendada de carregar fontes TTF/OTF

```c
Font LoadFontEx(const char *fileName, int fontSize, int *codepoints, int codepointCount);
```

- `fileName`: o arquivo da fonte
- `fontSize`: a altura em pixels em que os caracteres são gerados (o `baseSize`)
- `codepoints`: array com os caracteres (codepoints Unicode) a incluir. `NULL` carrega o conjunto padrão (ASCII)
- `codepointCount`: quantos itens o array tem. `0` com `codepoints = NULL`

- Devolve a `Font` com o atlas na GPU
- Precisa da janela criada

```c
// fonte nítida para títulos grandes
Font titulo = LoadFontEx("Inter-Bold.ttf", 72, NULL, 0);

// fonte com acentos do português
int n = 0;
int *cps = LoadCodepoints(" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                          "[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~áàâãéêíóôõúçÁÀÂÃÉÊÍÓÔÕÚÇ", &n);
Font texto = LoadFontEx("Inter-Regular.ttf", 24, cps, n);
UnloadCodepoints(cps);
```

---

**Escolhendo o tamanho**

- Carregue no tamanho em que o texto será desenhado (ou maior). Ampliar uma fonte pequena borra, reduzir uma grande pode serrilhar
- Fontes grandes com muitos caracteres geram atlas grandes: 72 pixels com centenas de caracteres pode ocupar vários megabytes de VRAM
- Ao reduzir, `SetTextureFilter(fonte.texture, TEXTURE_FILTER_BILINEAR)` suaviza o resultado

> Cada `LoadFontEx` com outro tamanho gera um atlas novo. Para usar a mesma fonte em 3 tamanhos, carregue 3 fontes, e libere cada uma com `UnloadFont` (ver `../font-loading.md`)
