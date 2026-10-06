**raylib**

> `raylib.h` (versão 5.5)

O raylib é uma biblioteca em C para criar jogos e aplicações gráficas de forma simples. Ela abre uma janela, lê teclado, mouse e gamepad, desenha formas, imagens, texto e modelos 3D com OpenGL, toca sons e músicas, sem que o programador precise lidar diretamente com a API do sistema operacional ou com o OpenGL

> O raylib não tem editor visual nem "engine": não existe cena, componente ou objeto de jogo. Ele entrega funções, e o programa decide tudo, inclusive quando desenhar e quando atualizar. Isso torna o fluxo do programa explícito e fácil de acompanhar

```c
#include "raylib.h"

int main(void) {
  InitWindow(800, 450, "meu jogo");
  SetTargetFPS(60);

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("ola, raylib", 190, 200, 20, DARKGRAY);
    EndDrawing();
  }

  CloseWindow();
  return 0;
}
```

- `InitWindow`: cria a janela e o contexto OpenGL. Nada pode ser desenhado nem carregado na GPU antes dele
- `while (!WindowShouldClose())`: o game loop, que roda uma vez por frame até o usuário fechar a janela ou apertar `Esc`
- `BeginDrawing` / `EndDrawing`: delimitam o desenho de um frame. O `EndDrawing` mostra o frame na tela e espera o tempo necessário para manter o FPS
- `CloseWindow`: fecha a janela e libera o contexto OpenGL

---

**Compilando**

```sh
# macOS (Homebrew) e Linux com pkg-config
gcc main.c -o jogo $(pkg-config --cflags --libs raylib)

# macOS, sem pkg-config
gcc main.c -o jogo -I/opt/homebrew/include -L/opt/homebrew/lib -lraylib

# Linux, linkando as dependências manualmente
gcc main.c -o jogo -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
```

- `pkg-config --cflags --libs raylib` devolve o `-I`, o `-L` e o `-l` corretos para a instalação atual
- Com a versão estática (`libraylib.a`) no Linux, é preciso linkar também as bibliotecas do sistema que o raylib usa (OpenGL, X11, pthread). No macOS, a versão estática exige os frameworks `-framework Cocoa -framework IOKit -framework OpenGL`
- Ver o processo de linking em `../compilers/gcc/doc/linking.md` e `../compilers/gcc/doc/libraries.md`

---

**Módulos**

O raylib é dividido em módulos, cada um em um arquivo `.c` interno, mas todos expostos pelo mesmo `raylib.h`:

| Módulo | O que faz | Documentação |
|--------|-----------|--------------|
| `rcore` | janela, game loop, tempo, monitor, input, arquivos | `core/`, `input/`, `files/` |
| `rshapes` | formas 2D e colisões 2D | `drawing/`, `collision/` |
| `rtextures` | imagens (CPU) e texturas (GPU) | `image/`, `texture/` |
| `rtext` | fontes e texto | `text/` |
| `rmodels` | modelos, meshes, materiais, colisões 3D | `models/`, `collision/` |
| `raudio` | dispositivo de áudio, sons, músicas | `audio/` |
| `rlgl` | camada sobre o OpenGL usada pelos outros módulos | `shaders/` |
| `raymath` | vetores, matrizes e quaternions (header separado, `raymath.h`) | `math/` |

- A câmera 2D/3D, usada para mover a visão do mundo, está em `camera/`
- Conceitos que valem para todos os módulos (game loop, delta time, CPU vs GPU, ciclo de vida dos recursos) estão em `concepts/`

---

**Tipos básicos**

```c
typedef struct Vector2   { float x, y; } Vector2;
typedef struct Vector3   { float x, y, z; } Vector3;
typedef struct Color     { unsigned char r, g, b, a; } Color;
typedef struct Rectangle { float x, y, width, height; } Rectangle;
```

- Quase toda função recebe e devolve essas structs **por valor**, e não por ponteiro. São pequenas, e copiá-las é barato
- Elas podem ser criadas com compound literals do C99: `(Vector2){ 100, 200 }`, `(Color){ 255, 0, 0, 255 }`
- O raylib define cores prontas como macros: `RED`, `GREEN`, `BLUE`, `WHITE`, `BLACK`, `RAYWHITE`, `DARKGRAY`, `BLANK` (transparente), etc (ver `drawing/colors.md`)

---

**Convenções da API**

- Funções de criação começam com `Load` (`LoadTexture`, `LoadSound`) e têm um par `Unload` que precisa ser chamado para liberar a memória (ver `concepts/resource-lifetime.md`)
- Funções de desenho começam com `Draw` e só funcionam entre `BeginDrawing` e `EndDrawing`
- Funções de consulta começam com `Is` (estado, devolve `bool`) ou `Get` (valor)
- Variações de uma mesma função usam sufixos:
    - `V`: recebe `Vector2` em vez de `x` e `y` separados (`DrawCircleV`)
    - `Rec`: recebe um `Rectangle` (`DrawRectangleRec`)
    - `Ex`: recebe parâmetros extras, como rotação e escala (`DrawTextureEx`)
    - `Pro`: versão mais completa, com origem, rotação e recorte (`DrawTexturePro`)
    - `Lines`: só o contorno (`DrawRectangleLines`)

> O raylib mantém estado global interno (a janela, o input, o tempo). Por isso as funções não recebem um "contexto" como parâmetro, e só pode existir uma janela por programa. A maior parte da API também não é thread-safe: chame as funções do raylib sempre da thread que chamou o `InitWindow`
