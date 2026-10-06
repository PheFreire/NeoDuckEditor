**SetWindowSize**

> `raylib.h` — módulo `rcore`

O `SetWindowSize` muda o tamanho da área de desenho da janela durante a execução. Funciona mesmo em janelas que o usuário não pode redimensionar

```c
void SetWindowSize(int width, int height);
```

- `width`: nova largura da área de desenho, em pixels
- `height`: nova altura da área de desenho, em pixels

- Não devolve nada
- O tamanho é da área de desenho, sem a barra de título e as bordas
- Depois da mudança, o `GetScreenWidth`/`GetScreenHeight` passam a devolver o novo tamanho e o `IsWindowResized` fica `true` no frame seguinte

```c
// menu de opções com resoluções pré-definidas
int resolucoes[][2] = { {800, 450}, {1280, 720}, {1920, 1080} };

if (IsKeyPressed(KEY_ONE))   SetWindowSize(resolucoes[0][0], resolucoes[0][1]);
if (IsKeyPressed(KEY_TWO))   SetWindowSize(resolucoes[1][0], resolucoes[1][1]);
if (IsKeyPressed(KEY_THREE)) SetWindowSize(resolucoes[2][0], resolucoes[2][1]);
```

---

**Limites de tamanho**

```c
SetWindowMinSize(640, 360);   // o usuário não consegue diminuir abaixo disso
SetWindowMaxSize(1920, 1080); // nem aumentar acima disso
```

- Úteis em janelas com `FLAG_WINDOW_RESIZABLE`, para impedir tamanhos que quebram a interface

> Mudar o tamanho da janela não muda o tamanho das render textures nem o `offset` das câmeras 2D que dependem dele. Recrie ou recalcule esses valores depois de chamar o `SetWindowSize` (ver `is-window-resized.md`)
