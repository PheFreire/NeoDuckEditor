**core**

> `raylib.h` — módulo `rcore`

O `core` é o módulo central do raylib: cria e controla a janela, mantém o game loop, mede o tempo entre frames, consulta os monitores, controla o cursor, a área de transferência e as mensagens de log. Todos os outros módulos dependem dele, pois é o `InitWindow` que cria o contexto OpenGL usado para desenhar

```c
#include "raylib.h"

int main(void) {
  SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_VSYNC_HINT);  // antes do InitWindow
  InitWindow(800, 450, "core");
  SetTargetFPS(60);

  while (!WindowShouldClose()) {
    float dt = GetFrameTime();
    // atualizar o jogo usando dt

    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText(TextFormat("FPS: %d", GetFPS()), 10, 10, 20, DARKGRAY);
    EndDrawing();
  }

  CloseWindow();
  return 0;
}
```

---

**Conteúdo**

| Assunto | O que cobre | Ver |
|---------|-------------|-----|
| janela | criar, fechar, estados, tamanho, posição, fullscreen | `window.md` |
| game loop | a estrutura de um programa raylib | `application-loop.md` |
| tempo | FPS, delta time, tempo total | `timing.md` |
| monitor | quantidade, tamanho e taxa de atualização dos monitores | `monitor.md` |
| cursor | mostrar, esconder e travar o cursor | `cursor.md` |
| clipboard | copiar e colar texto | `clipboard.md` |
| logging | mensagens do raylib e do programa | `logging.md` |

- Cada função tem sua própria nota em `functions/`

---

**Ordem obrigatória**

```text
SetConfigFlags()        opcional, configura a janela antes de ela existir
  │
  ▼
InitWindow()            cria a janela e o contexto OpenGL
  │
  ▼
Load...()               texturas, fontes, shaders, modelos (precisam do OpenGL)
  │
  ▼
game loop               while (!WindowShouldClose()) { atualizar, desenhar }
  │
  ▼
Unload...()             libera tudo que foi carregado
  │
  ▼
CloseWindow()           destrói o contexto OpenGL e a janela
```

- Carregar uma textura antes do `InitWindow` falha, pois a GPU ainda não está acessível (ver `../concepts/cpu-vs-gpu.md`)
- Liberar recursos depois do `CloseWindow` também é um erro: o contexto que eles usavam não existe mais

> O `core` também contém o input (`../input/`) e as funções de arquivo (`../files/`), que foram separados nesta documentação por serem assuntos grandes. No código-fonte do raylib, tudo isso fica no mesmo `rcore.c`
