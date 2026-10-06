**Screen space**

> espaço da tela

O screen space (espaço da tela) é o sistema de coordenadas dos pixels da janela. A origem fica no canto superior esquerdo, `x` cresce para a direita e `y` para baixo, até `(GetScreenWidth(), GetScreenHeight())`. É onde ficam o mouse e a interface do jogo

```text
(0, 0) ─────────────────────────────────────► x
  │  ♥♥♥                      pontos: 1200       ← interface (HUD): fixa
  │
  │            mundo, visto pela câmera
  │
  │  [ inventário ]
  ▼                                (largura, altura)
  y
```

---

**O que pertence à tela**

- A posição do mouse e dos toques
- A interface: vida, pontuação, menus, botões, minimapa, textos fixos
- Tudo desenhado fora de `BeginMode2D`/`BeginMode3D`
- A área do scissor mode

---

**Interface que acompanha o mundo**

Um texto sobre um inimigo precisa ficar sobre ele (mundo), mas com tamanho fixo (tela). A posição é convertida do mundo para a tela, e o desenho é feito fora da câmera:

```c
EndMode2D();
Vector2 t = GetWorldToScreen2D(inimigo.pos, camera);
DrawText(inimigo.nome, (int)t.x, (int)t.y - 30, 16, RED);
```

---

**Resolução e proporção**

- Posições fixas (`DrawText(..., 700, 10, ...)`) quebram quando a janela muda de tamanho
- Ancore a interface nas bordas e no centro usando `GetScreenWidth()` e `GetScreenHeight()`
- Para manter a mesma aparência em qualquer resolução, uma alternativa é desenhar tudo em uma render texture de tamanho fixo e ampliá-la para a janela (ver `../texture/render-texture.md`)

> O mouse sempre chega em screen space. Testar o mouse diretamente contra objetos do mundo só funciona enquanto a câmera não se move: converta com `GetScreenToWorld2D` (ver `../camera/coordinate-conversion.md`)
