**Camera2D**

> `raylib.h` — módulo `rcore`

A `Camera2D` controla a visão de uma cena 2D: qual ponto do mundo aparece em qual ponto da tela, com quanto zoom e com qual rotação. É usada para seguir o jogador, mostrar mapas maiores que a tela e dar zoom

```c
typedef struct Camera2D {
  Vector2 offset;    // ponto da TELA onde o target aparece
  Vector2 target;    // ponto do MUNDO que a câmera observa (origem da rotação e do zoom)
  float rotation;    // rotação em graus
  float zoom;        // escala: 1.0 = normal, 2.0 = tudo 2x maior
} Camera2D;
```

---

**offset e target**

```text
MUNDO                                    TELA (800x450)
                                         ┌──────────────────────┐
     target = (1000, 600)                │                      │
            ●  ───── aparece em ─────►   │          ● offset    │
         jogador                         │       (400, 225)     │
                                         └──────────────────────┘
```

- `target`: **o que** a câmera mostra (um ponto do mundo)
- `offset`: **onde** esse ponto aparece na tela
- Com `offset` no centro da tela e `target` na posição do jogador, o jogador fica sempre centralizado
- Com `offset = (0, 0)` e `target = (0, 0)`, mundo e tela coincidem: a câmera não altera nada

---

**Seguindo o jogador**

```c
Camera2D cam = { 0 };
cam.zoom = 1.0f;

while (!WindowShouldClose()) {
  atualizar_jogador(&jogador);

  cam.offset = (Vector2){ GetScreenWidth() / 2.0f, GetScreenHeight() / 2.0f };
  cam.target = jogador;   // a câmera vai exatamente para o jogador

  BeginDrawing();
  ClearBackground(SKYBLUE);
  BeginMode2D(cam);
    desenhar_mundo();
  EndMode2D();
  EndDrawing();
}
```

Seguindo com suavidade:

```c
float suavidade = 5.0f;   // maior = acompanha mais rápido
cam.target.x += (jogador.x - cam.target.x) * suavidade * GetFrameTime();
cam.target.y += (jogador.y - cam.target.y) * suavidade * GetFrameTime();
```

Limitando ao tamanho do mapa:

```c
float meia_l = GetScreenWidth()  / 2.0f / cam.zoom;
float meia_a = GetScreenHeight() / 2.0f / cam.zoom;
cam.target.x = Clamp(cam.target.x, meia_l, largura_mapa - meia_l);
cam.target.y = Clamp(cam.target.y, meia_a, altura_mapa - meia_a);
```

- Dividir pelo `zoom` dá o tamanho da tela em unidades do mundo: com zoom 2, a tela mostra metade do mundo

---

**Zoom e rotação**

- `zoom` maior que `1` aproxima, menor que `1` afasta. Nunca deixe chegar a `0`, que colapsa tudo em um ponto
- `rotation` gira o mundo em torno do `target`. Útil para efeitos (tremer, inclinar), raramente para a câmera normal de um jogo

> A câmera 2D só afeta o que é desenhado entre `BeginMode2D` e `EndMode2D`. A interface (vida, pontuação, menus) deve ser desenhada depois do `EndMode2D`, para ficar fixa na tela (ver `screen-space.md`)
