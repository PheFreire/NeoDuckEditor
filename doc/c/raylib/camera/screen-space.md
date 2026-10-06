**Espaço da tela**

> screen space

O espaço da tela é o sistema de coordenadas dos pixels da janela: `(0, 0)` no canto superior esquerdo e `(GetScreenWidth(), GetScreenHeight())` no canto inferior direito. É o espaço do mouse, da interface e de tudo que é desenhado fora de um modo de câmera

```text
(0, 0) ───────────────────────────────► x
  │ ♥♥♥  pontos: 1200          (HUD fixo)
  │
  │        mundo visto pela câmera
  │
  │ [ menu ]
  ▼                     (largura, altura)
  y
```

---

**O que fica no espaço da tela**

- A posição do mouse (`GetMousePosition`) e dos toques (`GetTouchPosition`)
- A interface: vida, pontuação, minimapa, menus, mensagens
- Tudo que é desenhado **fora** de `BeginMode2D`/`BeginMode3D`
- A área do `BeginScissorMode`

```c
BeginDrawing();
ClearBackground(RAYWHITE);

BeginMode2D(camera);
  desenhar_mundo();                 // espaço do mundo: move com a câmera
EndMode2D();

DrawText(TextFormat("Pontos: %d", pontos), 10, 10, 20, BLACK);   // espaço da tela: fixo
DrawFPS(GetScreenWidth() - 90, 10);
EndDrawing();
```

---

**Interface que acompanha objetos do mundo**

Um nome ou uma barra de vida em cima de um inimigo precisa ficar sobre ele (mundo), mas com tamanho fixo na tela. A solução é converter a posição do mundo para a tela e desenhar fora da câmera:

```c
EndMode2D();

Vector2 tela = GetWorldToScreen2D(inimigo.pos, camera);
DrawText(inimigo.nome, (int)tela.x - 20, (int)tela.y - 40, 16, RED);   // não aumenta com o zoom
```

> Posições da tela mudam com o tamanho da janela. Ancore a interface nas bordas usando `GetScreenWidth()` e `GetScreenHeight()`, em vez de posições fixas, para ela continuar correta em qualquer resolução (ver `../core/functions/get-screen-width.md`)
