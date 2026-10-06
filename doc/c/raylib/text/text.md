**text**

> `raylib.h` — módulo `rtext`

O módulo de texto desenha texto na tela usando fontes, mede o tamanho que um texto vai ocupar e oferece funções utilitárias para strings: formatar com variáveis, contar o tamanho, converter para número e trabalhar com UTF-8. O raylib já vem com uma fonte padrão embutida, então é possível desenhar texto sem carregar nenhum arquivo

```c
DrawText("Ola, raylib!", 100, 100, 20, DARKGRAY);                 // fonte padrão
DrawText(TextFormat("Pontos: %d", pontos), 10, 10, 20, BLACK);     // texto com variáveis

Font fonte = LoadFontEx("Roboto.ttf", 32, NULL, 0);
DrawTextEx(fonte, "Fonte própria", (Vector2){ 100, 200 }, 32, 1, BLUE);
UnloadFont(fonte);
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| o que é uma fonte no raylib (atlas de glifos) | `fonts.md` |
| carregar fontes TTF/OTF e bitmap | `font-loading.md` |
| desenhar texto, tamanho, espaçamento, rotação | `text-drawing.md` |
| medir texto para centralizar e alinhar | `text-measurement.md` |
| UTF-8, codepoints e acentos | `unicode.md` |

- Cada função tem sua nota em `functions/`

---

**Funções**

| Grupo | Funções |
|-------|---------|
| fontes | `GetFontDefault`, `LoadFont`, `LoadFontEx`, `UnloadFont` |
| desenho | `DrawText`, `DrawTextEx`, `DrawTextPro`, `DrawFPS` |
| medida | `MeasureText`, `MeasureTextEx` |
| strings | `TextFormat`, `TextLength`, `TextToInteger` |
| UTF-8 | `GetCodepoint`, `CodepointToUTF8` |

> Texto é desenhado como texturas: cada letra é um pedaço de uma imagem com todas as letras da fonte (o atlas), desenhado com dois triângulos. Por isso, desenhar texto no raylib tem o mesmo custo que desenhar pequenos sprites (ver `fonts.md`)
