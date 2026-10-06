**MeasureTextEx**

> `raylib.h` — módulo `rtext`

O `MeasureTextEx` calcula a largura e a altura que um texto vai ocupar quando desenhado com uma fonte, tamanho e espaçamento específicos

```c
Vector2 MeasureTextEx(Font font, const char *text, float fontSize, float spacing);
```

- `font`: a fonte
- `text`: o texto
- `fontSize`: o tamanho usado no desenho
- `spacing`: o espaçamento usado no desenho

- Devolve um `Vector2` com a largura em `x` e a altura em `y`
- Com várias linhas, a largura é a da linha mais longa e a altura soma as linhas

```c
Font fonte = LoadFontEx("Inter.ttf", 32, NULL, 0);
const char *titulo = "Configurações";

Vector2 tam = MeasureTextEx(fonte, titulo, 32, 1);

// caixa com padding em volta do texto
Rectangle caixa = { 100, 100, tam.x + 20, tam.y + 10 };
DrawRectangleRec(caixa, Fade(BLACK, 0.7f));
DrawTextEx(fonte, titulo, (Vector2){ caixa.x + 10, caixa.y + 5 }, 32, 1, WHITE);
```

> Os parâmetros precisam ser idênticos aos do `DrawTextEx`. Medir com espaçamento `1` e desenhar com `2` faz a caixa ficar menor que o texto
