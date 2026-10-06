**DrawTextEx**

> `raylib.h` — módulo `rtext`

O `DrawTextEx` desenha um texto com uma fonte escolhida, posição em `Vector2` e espaçamento entre letras configurável

```c
void DrawTextEx(Font font, const char *text, Vector2 position, float fontSize, float spacing, Color tint);
```

- `font`: a fonte (carregada com `LoadFontEx` ou `GetFontDefault()`)
- `text`: o texto, em UTF-8
- `position`: o canto superior esquerdo
- `fontSize`: a altura das letras, em pixels
- `spacing`: espaço extra entre as letras, em pixels
- `tint`: a cor

- Não devolve nada

```c
Font fonte = LoadFontEx("Inter.ttf", 32, NULL, 0);

DrawTextEx(fonte, "Título", (Vector2){ 20, 20 }, 32, 1, BLACK);
DrawTextEx(fonte, "E S P A Ç A D O", (Vector2){ 20, 70 }, 32, 8, GRAY);
```

---

**fontSize e baseSize**

```text
fontSize = baseSize       → nítido (escala 1)
fontSize = 2 x baseSize   → ampliado, borra ou pixela
fontSize = baseSize / 2   → reduzido
```

- O texto é o atlas da fonte escalado para `fontSize / font.baseSize`. Para o melhor resultado, use o mesmo tamanho em que a fonte foi carregada

> Para medir o texto antes de desenhar, use o `MeasureTextEx` com a mesma fonte, tamanho e espaçamento (ver `measure-text-ex.md`)
