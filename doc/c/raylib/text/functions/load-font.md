**LoadFont**

> `raylib.h` — módulo `rtext`

O `LoadFont` carrega uma fonte de um arquivo (TTF, OTF, FNT ou imagem) com as configurações padrão: para fontes vetoriais, os caracteres ASCII rasterizados em 32 pixels

```c
Font LoadFont(const char *fileName);
```

- `fileName`: o arquivo da fonte

- Devolve a `Font` carregada, com o atlas na GPU
- Para TTF/OTF: 95 caracteres (ASCII imprimível) com `baseSize` de 32 pixels
- Se falhar, escreve um aviso no log e devolve a fonte padrão. Confira com `IsFontValid` ou comparando a textura com a da `GetFontDefault()`
- Precisa da janela criada

```c
Font fonte = LoadFont("assets/Inter.ttf");
DrawTextEx(fonte, "Ola", (Vector2){ 20, 20 }, 32, 1, BLACK);   // tamanho igual ao baseSize: nítido
UnloadFont(fonte);
```

> Para escolher o tamanho de rasterização ou incluir caracteres acentuados, use o `LoadFontEx`. Desenhar uma fonte carregada em 32 pixels com tamanho 96 a deixa borrada (ver `load-font-ex.md` e `../fonts.md`)
