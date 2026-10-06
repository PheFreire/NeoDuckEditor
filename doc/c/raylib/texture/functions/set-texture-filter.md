**SetTextureFilter**

> `raylib.h` — módulo `rtextures`

O `SetTextureFilter` define como a GPU calcula as cores quando a textura é desenhada em um tamanho diferente do original: pixelado (point) ou suave (bilinear, trilinear, anisotrópico)

```c
void SetTextureFilter(Texture2D texture, int filter);
```

- `texture`: a textura
- `filter`: o filtro:
    - `TEXTURE_FILTER_POINT`: pixel mais próximo, nítido (padrão)
    - `TEXTURE_FILTER_BILINEAR`: mistura os 4 pixels vizinhos, suave
    - `TEXTURE_FILTER_TRILINEAR`: bilinear com mipmaps
    - `TEXTURE_FILTER_ANISOTROPIC_4X`, `8X`, `16X`: qualidade em ângulos inclinados (3D)

- Não devolve nada
- O filtro fica gravado na textura: vale para todos os desenhos seguintes

```c
Texture2D ui = LoadTexture("botao.png");
SetTextureFilter(ui, TEXTURE_FILTER_BILINEAR);   // interface escalada fica suave

Texture2D sprite = LoadTexture("heroi_16.png");  // pixel art: mantém o padrão POINT
```

> O filtro trilinear sem mipmaps se comporta como bilinear. Gere os mipmaps antes com `GenTextureMipmaps` (ver `../texture-filtering.md`)
