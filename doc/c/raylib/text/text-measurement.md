**Medindo texto**

> `raylib.h` — módulo `rtext`

Para centralizar, alinhar à direita ou encaixar um texto em uma caixa, é preciso saber quanto espaço ele ocupa antes de desenhar. O `MeasureText` mede a largura com a fonte padrão, e o `MeasureTextEx` mede largura e altura com qualquer fonte

```c
int MeasureText(const char *text, int fontSize);
Vector2 MeasureTextEx(Font font, const char *text, float fontSize, float spacing);
```

- `MeasureText`: devolve a largura em pixels, com a fonte padrão
- `MeasureTextEx`: devolve a largura em `x` e a altura em `y`, com a fonte e o espaçamento passados

---

**Centralizando**

```c
const char *titulo = "MEU JOGO";
int tamanho = 40;
int largura = MeasureText(titulo, tamanho);

DrawText(titulo, (GetScreenWidth() - largura) / 2, 100, tamanho, DARKGRAY);
```

```text
|←──────────── GetScreenWidth() ────────────→|
|←── (tela - largura) / 2 ──→|←─ largura ─→|
                             MEU JOGO
```

Com uma fonte própria:

```c
Vector2 m = MeasureTextEx(fonte, titulo, 48, 2);
Vector2 pos = { (GetScreenWidth() - m.x) / 2, (GetScreenHeight() - m.y) / 2 };   // centro da tela
DrawTextEx(fonte, titulo, pos, 48, 2, WHITE);
```

---

**Alinhar à direita**

```c
const char *pontos = TextFormat("%d", pontuacao);
DrawText(pontos, GetScreenWidth() - MeasureText(pontos, 30) - 10, 10, 30, BLACK);
```

---

**Mesmos parâmetros para medir e desenhar**

- A medida só é correta se a fonte, o tamanho e o espaçamento forem os mesmos do desenho
- O `MeasureText` usa a fonte padrão com o espaçamento que o `DrawText` usa. Para uma fonte carregada, use sempre o `MeasureTextEx` com o mesmo `spacing` passado ao `DrawTextEx`
- Com várias linhas (`\n`), a largura é a da linha mais longa, e a altura soma as linhas

> Medir texto todo frame é barato para algumas dezenas de textos. Em interfaces com textos fixos, a medida pode ser calculada uma vez e guardada, recalculando só quando o texto ou a janela mudarem
