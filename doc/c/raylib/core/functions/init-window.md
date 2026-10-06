**InitWindow**

> `raylib.h` — módulo `rcore`

O `InitWindow` cria a janela do programa e o contexto OpenGL usado por todo o resto do raylib. Também inicializa o input, o tempo e carrega a fonte padrão. Deve ser a primeira função do raylib a ser chamada, com exceção das funções de configuração como `SetConfigFlags` e `SetTraceLogLevel`

```c
void InitWindow(int width, int height, const char *title);
```

- `width`: largura da área de desenho, em pixels. `0` usa a largura do monitor
- `height`: altura da área de desenho, em pixels. `0` usa a altura do monitor
- `title`: texto da barra de título, em UTF-8

- Não devolve nada. Para saber se deu certo, use `IsWindowReady()`
- Cria **uma** janela. Chamar de novo sem `CloseWindow` antes não cria uma segunda
- O tamanho é da área de desenho, sem contar a barra de título e as bordas do sistema
- Inicia o relógio usado por `GetTime` e `GetFrameTime`

```c
#include "raylib.h"

int main(void) {
  SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_MSAA_4X_HINT);
  InitWindow(800, 450, "meu jogo");

  if (!IsWindowReady()) {
    return 1;   // falha ao criar a janela ou o contexto OpenGL
  }

  /* carregar recursos, game loop */

  CloseWindow();
  return 0;
}
```

---

**O que acontece por baixo**

```text
InitWindow
  │  cria a janela no sistema (GLFW no desktop)
  ▼
  │  cria o contexto OpenGL e carrega as funções do OpenGL
  ▼
  │  inicializa o rlgl: shader padrão, textura branca 1x1, buffers de vértices
  ▼
  │  carrega a fonte padrão (usada por DrawText)
  ▼
  │  inicia o relógio e o estado do input
  ▼
janela pronta
```

- Tudo que depende da GPU (texturas, fontes, shaders, render textures, modelos) só pode ser carregado **depois** dele (ver `../../concepts/cpu-vs-gpu.md`)
- O log mostra cada etapa e a versão do OpenGL obtida (ver `../logging.md`)

> Flags como `FLAG_MSAA_4X_HINT`, `FLAG_VSYNC_HINT` e `FLAG_WINDOW_TRANSPARENT` afetam a criação do contexto e precisam ser passadas com `SetConfigFlags` **antes** do `InitWindow`. Depois que a janela existe, elas não têm mais efeito
