**DrawText**

> `raylib.h` — módulo `rtext`

O `DrawText` desenha um texto na tela com a fonte padrão do raylib. É a forma mais simples de mostrar texto, sem precisar carregar nenhuma fonte

```c
void DrawText(const char *text, int posX, int posY, int fontSize, Color color);
```

- `text`: o texto, em UTF-8, terminado em `\0`
- `posX`, `posY`: o canto superior esquerdo do texto
- `fontSize`: a altura das letras, em pixels
- `color`: a cor do texto

- Não devolve nada
- O espaçamento entre letras é calculado automaticamente a partir do tamanho
- O `\n` quebra a linha

```c
DrawText("Pressione ENTER para começar", 200, 300, 20, GRAY);
DrawText(TextFormat("Fase %d", fase), 10, 10, 30, BLACK);
DrawText("linha 1\nlinha 2", 10, 60, 20, DARKGRAY);
```

---

**Tamanho e nitidez**

- A fonte padrão tem `baseSize` de 10 pixels. Tamanhos múltiplos de 10 (`10`, `20`, `30`...) ficam com os pixels uniformes. Outros tamanhos (como `15`) deixam alguns pixels maiores que outros

> Para fontes próprias, espaçamento manual ou posições em `float`, use o `DrawTextEx`. Para centralizar, meça antes com `MeasureText` (ver `../text-drawing.md` e `../text-measurement.md`)
