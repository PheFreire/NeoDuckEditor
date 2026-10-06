**IsWindowResized**

> `raylib.h` — módulo `rcore`

O `IsWindowResized` verifica se o tamanho da janela mudou no último frame, seja porque o usuário arrastou a borda, maximizou, restaurou, ou porque o programa chamou `SetWindowSize`

```c
bool IsWindowResized(void);
```

- Devolve `true` apenas no frame em que o tamanho mudou, e `false` nos outros
- Só acontece em janelas com `FLAG_WINDOW_RESIZABLE` (ou mudanças feitas pelo próprio programa)
- O novo tamanho é lido com `GetScreenWidth()` e `GetScreenHeight()`

```c
SetConfigFlags(FLAG_WINDOW_RESIZABLE);
InitWindow(800, 450, "redimensionável");

RenderTexture2D tela = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());

while (!WindowShouldClose()) {
  if (IsWindowResized()) {
    UnloadRenderTexture(tela);   // recria o que depende do tamanho da janela
    tela = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());
  }
  /* ... */
}
```

---

**O que normalmente depende do tamanho**

- Render textures do tamanho da tela (ver `../../texture/render-texture.md`)
- O `offset` de uma `Camera2D`, que costuma ser o centro da tela (ver `../../camera/camera-2d.md`)
- Posição de elementos da interface ancorados nas bordas ou no centro

> Em vez de reagir só ao `IsWindowResized`, muitos programas calculam as posições da interface a partir do `GetScreenWidth()` em todo frame. Assim nada fica desatualizado, e o custo de recalcular algumas posições é desprezível
