**DrawTexture**

> `raylib.h` — módulo `rtextures`

O `DrawTexture` desenha uma textura inteira, no tamanho original, com o canto superior esquerdo na posição indicada

```c
void DrawTexture(Texture2D texture, int posX, int posY, Color tint);
```

- `texture`: a textura a desenhar
- `posX`, `posY`: o canto superior esquerdo, na tela (ou no mundo, dentro de um `BeginMode2D`)
- `tint`: cor que multiplica os pixels: `WHITE` desenha sem alteração

- Não devolve nada

```c
DrawTexture(fundo, 0, 0, WHITE);
DrawTexture(heroi, 100, 300, WHITE);
DrawTexture(heroi, 200, 300, Fade(WHITE, 0.3f));   // fantasma meio transparente
DrawTexture(heroi, 300, 300, recebeu_dano ? RED : WHITE);
```

---

**Centralizando**

```c
// textura centralizada na tela
DrawTexture(logo, (GetScreenWidth() - logo.width) / 2, (GetScreenHeight() - logo.height) / 2, WHITE);
```

- A posição é o canto, e não o centro. Para centralizar, subtraia metade do tamanho da textura

> Para posições em `float`, use o `DrawTextureV`. Para girar ou escalar, o `DrawTextureEx`. Para desenhar só um pedaço, o `DrawTextureRec` (ver `../texture-drawing.md`)
