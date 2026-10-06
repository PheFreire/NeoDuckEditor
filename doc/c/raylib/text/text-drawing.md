**Desenhando texto**

> `raylib.h` — módulo `rtext`

O raylib tem três funções principais para desenhar texto: `DrawText`, com a fonte padrão e parâmetros simples, `DrawTextEx`, com uma fonte escolhida e espaçamento entre letras, e `DrawTextPro`, que também gira o texto em torno de uma origem

| Função | Fonte | Posição | Extras |
|--------|-------|---------|--------|
| `DrawText(texto, x, y, tamanho, cor)` | padrão | `int` | — |
| `DrawTextEx(fonte, texto, pos, tamanho, espaçamento, cor)` | escolhida | `Vector2` | espaçamento entre letras |
| `DrawTextPro(fonte, texto, pos, origem, rotação, tamanho, espaçamento, cor)` | escolhida | `Vector2` | rotação em torno da origem |
| `DrawFPS(x, y)` | padrão | `int` | mostra o FPS atual |

```c
DrawText("Fonte padrão", 20, 20, 20, DARKGRAY);
DrawTextEx(fonte, "Fonte própria", (Vector2){ 20, 60 }, 32, 2, BLUE);
DrawTextPro(fonte, "Girado", (Vector2){ 400, 225 }, (Vector2){ 0, 0 }, 30, 32, 2, RED);
```

---

**Posição e tamanho**

```text
(x, y) ● ┌──────────────────────┐
         │ Texto desenhado      │ ← tamanho = altura da linha, em pixels
         └──────────────────────┘
```

- A posição é o canto **superior esquerdo** do texto, e não a linha de base
- O tamanho é a altura das letras em pixels. A largura depende do texto e da fonte, e é obtida com `MeasureText` (ver `text-measurement.md`)

---

**Quebras de linha**

```c
DrawText("linha 1\nlinha 2\nlinha 3", 20, 20, 20, BLACK);
```

- O `\n` pula para a próxima linha, alinhada à esquerda com a posição inicial
- O espaço entre as linhas pode ser ajustado com `SetTextLineSpacing(pixels)`
- O raylib não quebra linhas automaticamente pela largura: textos longos precisam ter os `\n` inseridos pelo programa

---

**Texto com variáveis**

```c
DrawText(TextFormat("Vida: %d/%d", vida, vida_max), 10, 10, 20, RED);
DrawText(TextFormat("Tempo: %.1f s", GetTime()), 10, 40, 20, DARKGRAY);
```

- O `TextFormat` funciona como o `sprintf`, mas devolve um buffer interno do raylib, sem precisar declarar um array (ver `functions/text-format.md`)

---

**Contorno e sombra**

```c
// sombra: o mesmo texto deslocado, desenhado antes, em uma cor escura
DrawText("GAME OVER", 202, 202, 40, BLACK);
DrawText("GAME OVER", 200, 200, 40, RED);
```

> O texto é desenhado como sprites recortados do atlas da fonte, então segue a mesma ordem de desenho das texturas: o que é desenhado depois fica por cima. Para texto que acompanha objetos do mundo com tamanho fixo, desenhe fora do `BeginMode2D`, convertendo a posição com `GetWorldToScreen2D` (ver `../camera/screen-space.md`)
