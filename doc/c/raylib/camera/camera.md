**camera**

> `raylib.h` — módulos `rcore` e `rcamera`

Uma câmera define **qual parte do mundo aparece na tela e como**. Em vez de mover todos os objetos para dar a impressão de que o jogador anda, o programa move a câmera, e o raylib transforma tudo que é desenhado dentro do modo de câmera. Existem dois tipos: `Camera2D`, para jogos 2D (deslocamento, zoom e rotação), e `Camera3D`, para cenas 3D (posição, alvo e perspectiva)

```c
Camera2D cam = {
  .offset = { GetScreenWidth() / 2.0f, GetScreenHeight() / 2.0f },   // centro da tela
  .target = jogador,                                                // o que fica no centro
  .rotation = 0,
  .zoom = 1,
};

BeginDrawing();
ClearBackground(RAYWHITE);

BeginMode2D(cam);
  desenhar_mapa();       // coordenadas do mundo
  DrawCircleV(jogador, 16, BLUE);
EndMode2D();

DrawText("HUD", 10, 10, 20, BLACK);   // coordenadas da tela, fixo
EndDrawing();
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| câmera 2D: offset, target, zoom, rotação | `camera-2d.md` |
| câmera 3D: position, target, up, fovy, projeção | `camera-3d.md` |
| o espaço do mundo | `world-space.md` |
| o espaço da tela | `screen-space.md` |
| converter entre mundo e tela | `coordinate-conversion.md` |

- Cada função tem sua nota em `functions/`

---

**Dois sistemas de coordenadas**

```text
MUNDO (onde os objetos do jogo existem)
  │  a câmera escolhe uma região e aplica deslocamento, zoom e rotação
  ▼
TELA (os pixels da janela)
```

- Dentro de `BeginMode2D`/`BeginMode3D`, as posições passadas aos `Draw...` são do **mundo**
- Fora desses blocos, são da **tela**: é onde se desenha a interface (HUD), que não deve se mover com a câmera

---

**O que acontece por baixo**

- O `BeginMode2D` calcula uma matriz de transformação a partir da câmera e a aplica a todos os vértices desenhados até o `EndMode2D`
- O mundo em si não muda: um objeto em `(1000, 500)` continua em `(1000, 500)`. Só a forma como ele é projetado na tela muda
- O mesmo vale para o 3D, com uma matriz de visão (onde a câmera está e para onde olha) e uma de projeção (perspectiva ou ortográfica) (ver `../concepts/transformations.md`)

> Com uma câmera ativa, o mouse continua em coordenadas da tela. Para clicar em objetos do mundo, converta a posição do mouse (ver `coordinate-conversion.md`)
