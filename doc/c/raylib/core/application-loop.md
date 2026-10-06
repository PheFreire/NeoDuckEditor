**Application loop**

> estrutura de um programa raylib

Todo programa raylib segue a mesma estrutura: inicializa a janela, carrega os recursos, repete um laço que atualiza o estado e desenha o frame até o usuário fechar a janela, e por fim libera tudo. Esse laço é o **game loop**, e cada volta dele produz um frame na tela

```c
#include "raylib.h"

int main(void) {
  // 1. inicialização
  InitWindow(800, 450, "loop");
  SetTargetFPS(60);
  Texture2D jogador = LoadTexture("jogador.png");
  Vector2 pos = { 100, 100 };

  // 2. game loop
  while (!WindowShouldClose()) {
    // 2a. atualização: input, física, lógica
    float dt = GetFrameTime();
    if (IsKeyDown(KEY_RIGHT)) pos.x += 200 * dt;
    if (IsKeyDown(KEY_LEFT))  pos.x -= 200 * dt;

    // 2b. desenho: só desenha o estado atual
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawTextureV(jogador, pos, WHITE);
    EndDrawing();
  }

  // 3. finalização
  UnloadTexture(jogador);
  CloseWindow();
  return 0;
}
```

---

**O que cada parte faz**

```text
InitWindow ─► Load... ─┐
                       ▼
             ┌──► WindowShouldClose()? ── sim ──► Unload... ─► CloseWindow
             │         │ não
             │         ▼
             │    atualizar estado      (input, movimento, colisão)
             │         │
             │         ▼
             │    BeginDrawing
             │    ClearBackground
             │    Draw...               (desenha o estado atual)
             │    EndDrawing            (mostra o frame, espera, lê eventos)
             └─────────┘
```

- **Atualizar antes de desenhar**: separar as duas fases evita desenhar metade do frame com o estado antigo e metade com o novo
- **Desenhar só o estado**: o desenho não deve mudar o estado do jogo. Um frame desenhado duas vezes deveria sair igual
- **`EndDrawing` faz três coisas**: troca os buffers (mostra o frame), espera o tempo necessário para respeitar o `SetTargetFPS` e processa os eventos da janela e do input para o próximo frame (ver `../drawing/drawing-cycle.md`)
- **`WindowShouldClose`**: devolve `true` quando o usuário clica no botão de fechar ou aperta a tecla de saída (`Esc` por padrão, ver `../input/functions/set-exit-key.md`)

---

**Organizando o código**

Em programas maiores, cada fase vira uma função, deixando o `main` curto:

```c
typedef struct {
  Vector2 pos;
  Texture2D sprite;
} Jogo;

static void iniciar(Jogo *j)    { j->sprite = LoadTexture("jogador.png"); j->pos = (Vector2){ 100, 100 }; }
static void atualizar(Jogo *j, float dt) { if (IsKeyDown(KEY_RIGHT)) j->pos.x += 200 * dt; }
static void desenhar(const Jogo *j) { DrawTextureV(j->sprite, j->pos, WHITE); }
static void finalizar(Jogo *j)  { UnloadTexture(j->sprite); }

int main(void) {
  InitWindow(800, 450, "jogo");
  SetTargetFPS(60);
  Jogo jogo = {0};
  iniciar(&jogo);

  while (!WindowShouldClose()) {
    atualizar(&jogo, GetFrameTime());
    BeginDrawing();
    ClearBackground(RAYWHITE);
    desenhar(&jogo);
    EndDrawing();
  }

  finalizar(&jogo);
  CloseWindow();
  return 0;
}
```

---

**Armadilhas**

- Um laço infinito ou uma operação demorada dentro do game loop congela a janela inteira, pois os eventos só são processados no `EndDrawing`. O sistema operacional pode marcar o programa como "não respondendo"
- Esquecer o `BeginDrawing`/`EndDrawing` em algum caminho do laço (por exemplo, dentro de um `if`) faz a janela parar de atualizar e de responder
- Carregar recursos (`LoadTexture`, `LoadSound`) dentro do laço carrega o arquivo de novo a cada frame, consumindo memória até o programa travar. Carregue uma vez antes do laço

> O conceito geral de game loop, independente do raylib, está em `../concepts/game-loop.md`, e o uso do delta time para movimento independente do FPS está em `../concepts/delta-time.md`
