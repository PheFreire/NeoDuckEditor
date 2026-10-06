**GetFontDefault**

> `raylib.h` — módulo `rtext`

O `GetFontDefault` devolve a fonte padrão do raylib, embutida na biblioteca e carregada automaticamente pelo `InitWindow`. É a fonte usada pelo `DrawText` e pelo `MeasureText`

```c
Font GetFontDefault(void);
```

- Devolve a `Font` padrão: uma fonte bitmap com `baseSize` de 10 pixels e 224 caracteres (ASCII e Latin-1)
- Precisa da janela criada
- Não deve ser liberada com `UnloadFont`: pertence ao raylib e é liberada pelo `CloseWindow`

```c
// usar as funções Ex/Pro com a fonte padrão
Font padrao = GetFontDefault();
DrawTextEx(padrao, "espaçamento maior", (Vector2){ 20, 20 }, 20, 4, DARKGRAY);
DrawTextPro(padrao, "girado", (Vector2){ 400, 225 }, (Vector2){ 0, 0 }, 45, 20, 2, RED);
```

---

**Plano B quando uma fonte não carrega**

```c
Font fonte = LoadFontEx("assets/fonte.ttf", 32, NULL, 0);
bool fonte_propria = IsFontValid(fonte);
if (!fonte_propria) {
  fonte = GetFontDefault();
}

/* ... */

if (fonte_propria) UnloadFont(fonte);   // só libera a que foi carregada
```

> Como a fonte padrão tem 10 pixels de base, desenhá-la em tamanhos grandes a deixa pixelada. Para jogos com visual retrô isso é desejável. Para interfaces nítidas, carregue uma fonte TTF no tamanho certo (ver `../fonts.md`)
