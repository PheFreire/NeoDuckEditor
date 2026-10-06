**Desenhando texturas**

> `raylib.h` — módulo `rtextures`

O raylib tem várias funções para desenhar texturas, da mais simples (só a posição) à mais completa (recorte, destino com qualquer tamanho, origem e rotação). Todas recebem uma cor de `tint`, que multiplica as cores da textura: `WHITE` desenha a textura sem alteração

| Função | Parâmetros |
|--------|------------|
| `DrawTexture(t, x, y, tint)` | posição `int` |
| `DrawTextureV(t, pos, tint)` | posição `Vector2` |
| `DrawTextureEx(t, pos, rotação, escala, tint)` | rotação e escala uniforme |
| `DrawTextureRec(t, origem, pos, tint)` | só um pedaço (`Rectangle`) da textura |
| `DrawTexturePro(t, origem, destino, pivô, rotação, tint)` | pedaço, tamanho final, ponto de rotação |
| `DrawTextureNPatch(t, info, destino, pivô, rotação, tint)` | estica sem deformar as bordas (botões, painéis) |

```c
DrawTexture(fundo, 0, 0, WHITE);
DrawTextureV(heroi, pos, WHITE);
DrawTextureEx(heroi, pos, 45.0f, 2.0f, WHITE);   // girado 45 graus e 2x maior
DrawTexture(heroi, 100, 100, Fade(WHITE, 0.5f)); // meio transparente
DrawTexture(heroi, 100, 100, RED);               // avermelhado
```

---

**Spritesheet e animação**

```c
Texture2D folha = LoadTexture("andar.png");   // 4 frames de 32x32 lado a lado
int frame = 0;
float tempo = 0;

while (!WindowShouldClose()) {
  tempo += GetFrameTime();
  if (tempo >= 0.1f) {          // 10 frames por segundo
    tempo = 0;
    frame = (frame + 1) % 4;
  }

  Rectangle origem = { frame * 32, 0, 32, 32 };   // pedaço da folha
  BeginDrawing();
  ClearBackground(RAYWHITE);
  DrawTextureRec(folha, origem, pos, WHITE);
  EndDrawing();
}
```

- Espelhar na horizontal: `origem.width = -32` faz o frame ser desenhado invertido

---

**DrawTexturePro: o caso geral**

```text
textura (source)                       tela (dest)
┌──────────────────┐                   ┌─────────────┐
│   ┌──────┐       │   desenha o       │             │
│   │source│       │   pedaço source   │   ┌──────────────┐
│   └──────┘       │ ────────────────► │   │ dest (escala │
└──────────────────┘   no tamanho de   │   │ e rotação em │
                       dest            │   │ torno da     │
                                       │   │ origin)      │
                                       └───└──────────────┘
```

```c
Rectangle source = { 0, 0, heroi.width, heroi.height };     // a textura inteira
Rectangle dest   = { pos.x, pos.y, 64, 64 };                 // posição e tamanho na tela
Vector2 origin   = { 32, 32 };                               // girar em torno do centro do destino
DrawTexturePro(heroi, source, dest, origin, angulo, WHITE);
```

- `dest.x` e `dest.y` indicam onde o ponto `origin` fica na tela, como no `DrawRectanglePro` (ver `../drawing/functions/draw-rectangle-pro.md`)

> Toda função `DrawTexture...` recorta, escala e gira na GPU, sem custo de CPU. Por isso, efeitos que mudam todo frame (animação, rotação, piscar) devem ser feitos no desenho, e não editando a imagem
