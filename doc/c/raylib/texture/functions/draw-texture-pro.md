**DrawTexturePro**

> `raylib.h` — módulo `rtextures`

O `DrawTexturePro` é a função de desenho de textura mais completa: desenha um pedaço da textura (`source`) em um retângulo da tela com qualquer tamanho (`dest`), girando em torno de um ponto escolhido (`origin`). As outras funções `DrawTexture...` são casos particulares dela

```c
void DrawTexturePro(Texture2D texture, Rectangle source, Rectangle dest,
                    Vector2 origin, float rotation, Color tint);
```

- `texture`: a textura
- `source`: o pedaço da textura, em pixels da textura. Largura ou altura negativas espelham
- `dest`: o retângulo na tela: `dest.x`/`dest.y` indicam onde o ponto `origin` fica, e `dest.width`/`dest.height` o tamanho final
- `origin`: o ponto de rotação, relativo ao canto superior esquerdo do `dest` (em pixels do destino)
- `rotation`: rotação em graus, no sentido horário
- `tint`: cor que multiplica os pixels

- Não devolve nada

```c
// sprite de 32x32 desenhado com 64x64, girando em torno do próprio centro
Rectangle source = { 0, 0, 32, 32 };
Rectangle dest   = { pos.x, pos.y, 64, 64 };   // pos é o CENTRO, por causa da origin
Vector2 origin   = { 32, 32 };                  // metade do tamanho do destino
DrawTexturePro(nave, source, dest, origin, angulo, WHITE);
```

---

**Como os parâmetros se relacionam**

```text
textura                         tela
┌──────────────┐
│ ┌──────┐     │  source                 dest.x, dest.y
│ │      │     │  ───────►        ┌───────●───────┐ ← origin fica exatamente aqui
│ └──────┘     │  esticado para   │       ↻       │   e a rotação é em torno dele
└──────────────┘  dest.w x dest.h └───────────────┘
```

- Com `origin = (0, 0)`: `dest.x`/`dest.y` é o canto superior esquerdo, e a rotação é em torno do canto
- Com `origin = (dest.width / 2, dest.height / 2)`: `dest.x`/`dest.y` é o centro, e a rotação é em torno do centro

---

**Usos**

```c
// imagem esticada para cobrir a tela inteira
DrawTexturePro(fundo, (Rectangle){ 0, 0, fundo.width, fundo.height },
               (Rectangle){ 0, 0, GetScreenWidth(), GetScreenHeight() }, (Vector2){ 0 }, 0, WHITE);

// render texture desvirada e ampliada
DrawTexturePro(alvo.texture, (Rectangle){ 0, 0, 320, -180 },
               (Rectangle){ 0, 0, 1280, 720 }, (Vector2){ 0 }, 0, WHITE);
```

> O mesmo esquema de `dest` + `origin` + `rotation` aparece no `DrawRectanglePro` e no `DrawTextPro`. Entender esta função resolve a dúvida mais comum do raylib: "por que meu sprite gira em torno do canto?" (ver `../texture-drawing.md`)
