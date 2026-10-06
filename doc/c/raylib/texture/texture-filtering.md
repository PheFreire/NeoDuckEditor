**Filtro de textura**

> `raylib.h` — módulo `rtextures`

O filtro define como a GPU calcula a cor de um pixel da tela quando a textura é desenhada maior ou menor que o tamanho original. Com o filtro "point", cada pixel da tela pega a cor do pixel mais próximo da textura (resultado pixelado). Com o filtro bilinear, as cores vizinhas são misturadas (resultado suave)

```c
void SetTextureFilter(Texture2D texture, int filter);
```

| Filtro | Resultado | Uso |
|--------|-----------|-----|
| `TEXTURE_FILTER_POINT` | pixelado, nítido (padrão do raylib) | pixel art |
| `TEXTURE_FILTER_BILINEAR` | suave | fotos, ilustrações, interface escalada |
| `TEXTURE_FILTER_TRILINEAR` | suave, também entre mipmaps | texturas vistas de longe em 3D (precisa de mipmaps) |
| `TEXTURE_FILTER_ANISOTROPIC_4X` / `8X` / `16X` | suave mesmo em ângulos inclinados | chão e paredes em 3D |

```c
Texture2D pixel_art = LoadTexture("heroi_16x16.png");
// padrão já é POINT: escalar 4x mantém os pixels nítidos
DrawTextureEx(pixel_art, pos, 0, 4.0f, WHITE);

Texture2D foto = LoadTexture("paisagem.png");
SetTextureFilter(foto, TEXTURE_FILTER_BILINEAR);   // reduzir a foto sem serrilhado
```

---

**Ampliando**

```text
textura 2x2       POINT, 4x maior          BILINEAR, 4x maior
██ ░░             ████████░░░░░░░░          ███▓▓▒▒░░░░░
░░ ██             ████████░░░░░░░░          ▓▓▒▒▒▒▒▒▒▒▓▓
                  ░░░░░░░░████████          ▒▒▒▒▒▒▒▒▓▓██
                  ░░░░░░░░████████          ░░░░▒▒▓▓▓███
```

---

**Mipmaps**

- Mipmaps são versões menores da textura (1/2, 1/4, 1/8 do tamanho...) pré-calculadas
- Quando a textura aparece pequena na tela (longe da câmera), a GPU usa a versão menor, evitando o "chuvisco" (aliasing) e acelerando o desenho
- São gerados com `GenTextureMipmaps(&textura)` e usados pelos filtros trilinear e anisotrópico (ver `functions/gen-texture-mipmaps.md`)

> O filtro é uma propriedade da textura, e não de cada desenho: chame o `SetTextureFilter` uma vez, depois de carregar. Para jogos em pixel art que escalam a cena inteira, desenhe em uma render texture pequena com filtro point e amplie ela no final, o que mantém todos os pixels do mesmo tamanho (ver `render-texture.md`)
