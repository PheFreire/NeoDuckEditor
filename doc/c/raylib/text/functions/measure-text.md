**MeasureText**

> `raylib.h` — módulo `rtext`

O `MeasureText` calcula a largura, em pixels, que um texto vai ocupar quando desenhado com a fonte padrão em um tamanho. É usado para centralizar e alinhar texto desenhado com `DrawText`

```c
int MeasureText(const char *text, int fontSize);
```

- `text`: o texto
- `fontSize`: o tamanho que será usado no `DrawText`

- Devolve a largura em pixels
- Com várias linhas (`\n`), devolve a largura da linha mais longa

```c
const char *msg = "PAUSADO";
int tamanho = 40;
int x = (GetScreenWidth()  - MeasureText(msg, tamanho)) / 2;
int y = (GetScreenHeight() - tamanho) / 2;
DrawText(msg, x, y, tamanho, DARKGRAY);
```

---

**Botão que se ajusta ao texto**

```c
const char *rotulo = "Novo jogo";
int largura = MeasureText(rotulo, 20) + 40;   // 20 pixels de margem de cada lado
Rectangle botao = { 100, 100, largura, 40 };
DrawRectangleRec(botao, LIGHTGRAY);
DrawText(rotulo, botao.x + 20, botao.y + 10, 20, BLACK);
```

> O `MeasureText` só mede a largura. A altura de uma linha é o próprio `fontSize`. Para fontes carregadas, ou para obter a largura e a altura juntas, use o `MeasureTextEx` (ver `measure-text-ex.md`)
