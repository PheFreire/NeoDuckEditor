**UpdateCamera**

> `raylib.h` — módulo `rcamera`

O `UpdateCamera` move e gira uma câmera 3D de acordo com o teclado e o mouse, usando um dos modos prontos do raylib (primeira pessoa, terceira pessoa, orbital, livre). É uma forma rápida de navegar por uma cena 3D sem escrever o controle da câmera

```c
void UpdateCamera(Camera *camera, int mode);
```

- `camera`: ponteiro para a câmera a atualizar (ela é modificada)
- `mode`: o modo de controle:
    - `CAMERA_CUSTOM`: não faz nada
    - `CAMERA_FREE`: voo livre
    - `CAMERA_ORBITAL`: gira ao redor do `target`
    - `CAMERA_FIRST_PERSON`: primeira pessoa
    - `CAMERA_THIRD_PERSON`: terceira pessoa

- Não devolve nada
- Deve ser chamado uma vez por frame, antes de desenhar

```c
Camera3D cam = {
  .position = { 0, 2, 4 }, .target = { 0, 2, 0 }, .up = { 0, 1, 0 },
  .fovy = 60, .projection = CAMERA_PERSPECTIVE,
};
DisableCursor();   // trava o mouse para girar a câmera

while (!WindowShouldClose()) {
  UpdateCamera(&cam, CAMERA_FIRST_PERSON);

  BeginDrawing();
  ClearBackground(SKYBLUE);
  BeginMode3D(cam);
    DrawPlane((Vector3){ 0 }, (Vector2){ 32, 32 }, LIGHTGRAY);
    DrawCube((Vector3){ 4, 1, 4 }, 2, 2, 2, RED);
  EndMode3D();
  EndDrawing();
}
```

---

**Controles padrão**

| Modo | Controles |
|------|-----------|
| `CAMERA_FIRST_PERSON` | `W`/`A`/`S`/`D` andam, mouse gira, sem voar |
| `CAMERA_FREE` | `W`/`A`/`S`/`D` andam, mouse gira, `Space`/`Ctrl` sobem e descem |
| `CAMERA_ORBITAL` | gira sozinha ao redor do `target`, roda do mouse dá zoom |
| `CAMERA_THIRD_PERSON` | anda e gira em torno do `target` |

- A câmera é modificada pelo ponteiro, por isso o `&cam`

---

**Controle próprio**

Para controles específicos do jogo, o raylib 5 expõe as funções usadas internamente pelo `UpdateCamera` (em `rcamera.h`):

```c
#include "rcamera.h"

CameraMoveForward(&cam, 5.0f * dt, true);   // anda para frente, sem sair do plano (true)
CameraYaw(&cam, -GetMouseDelta().x * 0.003f, false);
CameraPitch(&cam, -GetMouseDelta().y * 0.003f, true, false, false);
```

- O `rcamera.h` fica na pasta `src/` do código-fonte do raylib e não é instalado junto com o `raylib.h` (o Homebrew, por exemplo, instala só `raylib.h`, `raymath.h` e `rlgl.h`). As funções já estão compiladas dentro da `libraylib`, então basta copiar o header para o projeto
- Também existe o `UpdateCameraPro(&cam, movimento, rotacao, zoom)`, declarado no próprio `raylib.h`, que aplica valores calculados pelo programa em vez de ler o input

> O `UpdateCamera` lê o input diretamente, sem saber das regras do jogo (paredes, menus abertos, colisões). Em jogos completos, a câmera costuma ser controlada pelo próprio código, usando `CAMERA_CUSTOM` ou as funções do `rcamera.h`
