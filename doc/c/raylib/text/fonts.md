**Fontes**

> `raylib.h` — tipo `Font`

Uma `Font` no raylib não é o arquivo TTF em si: é uma **textura** com todas as letras já desenhadas (o atlas de glifos), mais uma tabela que diz onde cada letra está no atlas e como posicioná-la. O arquivo de fonte só é lido no carregamento, quando as letras são rasterizadas em um tamanho fixo

```c
typedef struct GlyphInfo {
  int value;      // o caractere (codepoint Unicode)
  int offsetX;    // deslocamento ao desenhar
  int offsetY;
  int advanceX;   // quanto avançar até a próxima letra
  Image image;    // a imagem da letra
} GlyphInfo;

typedef struct Font {
  int baseSize;          // tamanho em que as letras foram geradas (pixels)
  int glyphCount;        // quantos caracteres a fonte tem
  int glyphPadding;      // espaço em volta de cada letra no atlas
  Texture2D texture;     // o atlas com todas as letras
  Rectangle *recs;       // onde cada letra está no atlas
  GlyphInfo *glyphs;     // informações de cada letra
} Font;
```

---

**O atlas**

```text
texture (atlas)                      desenhar "OLA":
┌─────────────────────────────┐
│ A B C D E F G H I J K L M   │      recs['O'] ─► recorta o O do atlas e desenha
│ N O P Q R S T U V W X Y Z   │      recs['L'] ─► recorta o L, avança advanceX
│ a b c d e f g ...           │      recs['A'] ─► ...
│ 0 1 2 3 ... ! ? . ,         │
└─────────────────────────────┘
```

- Cada letra desenhada é um pedaço do atlas (como um sprite de uma spritesheet)
- Só existem no atlas os caracteres escolhidos no carregamento. Por padrão, os 95 caracteres ASCII imprimíveis (do espaço ao `~`). Letras acentuadas precisam ser pedidas explicitamente (ver `unicode.md`)

---

**baseSize e qualidade**

- As letras são rasterizadas uma vez, em `baseSize` pixels. Desenhar em um tamanho diferente **escala a textura**
- Desenhar muito maior que o `baseSize` deixa o texto borrado ou pixelado. Desenhar muito menor desperdiça memória e pode serrilhar
- Por isso o `LoadFontEx` recebe o tamanho: carregue a fonte no tamanho em que ela vai ser usada, ou maior, e use o filtro bilinear se for reduzir

```c
Font titulo = LoadFontEx("fonte.ttf", 64, NULL, 0);   // para títulos de 64 pixels
Font texto  = LoadFontEx("fonte.ttf", 20, NULL, 0);   // para o texto do jogo
SetTextureFilter(titulo.texture, TEXTURE_FILTER_BILINEAR);
```

---

**Fonte padrão**

- O raylib carrega uma fonte bitmap pequena (`baseSize` de 10 pixels) no `InitWindow`, usada pelo `DrawText` e pelo `MeasureText`
- Ela tem 224 caracteres: o ASCII imprimível e os caracteres do Latin-1 (de `32` a `255`), o que inclui as letras acentuadas do português
- Por ser pequena, ela fica pixelada em tamanhos grandes, o que combina com jogos retrô, mas não com interfaces modernas

> Uma `Font` contém uma textura, então segue as mesmas regras: precisa da janela criada para ser carregada e de um `UnloadFont` antes do `CloseWindow` (ver `functions/unload-font.md`)
