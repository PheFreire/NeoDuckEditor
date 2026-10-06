**Janela**

> `raylib.h` — módulo `rcore`

A janela é o primeiro recurso de todo programa raylib. Ela é criada com `InitWindow`, que também cria o contexto OpenGL, e destruída com `CloseWindow`. Entre os dois, o programa pode consultar e alterar o estado da janela: tamanho, posição, título, fullscreen, minimizada, maximizada, com ou sem foco

```c
SetConfigFlags(FLAG_WINDOW_RESIZABLE);   // flags que precisam existir antes da janela
InitWindow(800, 450, "titulo");

while (!WindowShouldClose()) {
  if (IsKeyPressed(KEY_F11)) {
    ToggleFullscreen();
  }
  if (IsWindowResized()) {
    TraceLog(LOG_INFO, "novo tamanho: %dx%d", GetScreenWidth(), GetScreenHeight());
  }
  /* ... */
}

CloseWindow();
```

---

**Funções**

| Grupo | Funções |
|-------|---------|
| ciclo de vida | `InitWindow`, `CloseWindow`, `WindowShouldClose`, `IsWindowReady` |
| estado | `IsWindowFullscreen`, `IsWindowHidden`, `IsWindowMinimized`, `IsWindowMaximized`, `IsWindowFocused`, `IsWindowResized` |
| flags | `SetWindowState`, `ClearWindowState` |
| ações | `ToggleFullscreen`, `MaximizeWindow`, `MinimizeWindow`, `RestoreWindow` |
| propriedades | `SetWindowTitle`, `SetWindowPosition`, `SetWindowSize`, `GetScreenWidth`, `GetScreenHeight` |

- Cada uma tem sua nota em `functions/` (ex: `functions/init-window.md`)

---

**Flags de configuração**

O estado da janela é guardado como um conjunto de bits (`ConfigFlags`), combinados com `|`:

| Flag | Efeito |
|------|--------|
| `FLAG_VSYNC_HINT` | sincroniza a troca de frames com a taxa do monitor |
| `FLAG_FULLSCREEN_MODE` | fullscreen exclusivo |
| `FLAG_BORDERLESS_WINDOWED_MODE` | janela sem borda do tamanho do monitor |
| `FLAG_WINDOW_RESIZABLE` | o usuário pode redimensionar a janela |
| `FLAG_WINDOW_UNDECORATED` | sem barra de título e bordas |
| `FLAG_WINDOW_HIDDEN` | janela invisível |
| `FLAG_WINDOW_MINIMIZED` / `FLAG_WINDOW_MAXIMIZED` | minimizada / maximizada |
| `FLAG_WINDOW_UNFOCUSED` | sem foco |
| `FLAG_WINDOW_TOPMOST` | sempre acima das outras janelas |
| `FLAG_WINDOW_ALWAYS_RUN` | continua rodando quando minimizada |
| `FLAG_WINDOW_TRANSPARENT` | framebuffer com transparência |
| `FLAG_WINDOW_HIGHDPI` | suporte a telas HighDPI (Retina) |
| `FLAG_MSAA_4X_HINT` | antialiasing 4x |

- `SetConfigFlags(flags)`: define as flags **antes** do `InitWindow`. Obrigatório para as flags que afetam a criação do contexto, como `FLAG_MSAA_4X_HINT`, `FLAG_VSYNC_HINT` e `FLAG_WINDOW_TRANSPARENT`
- `SetWindowState(flags)` / `ClearWindowState(flags)`: ligam e desligam flags **depois** que a janela existe
- `IsWindowState(flag)`: verifica se uma flag está ligada
- A combinação com `|` funciona porque cada flag é um bit diferente (ver `../../termios/terminal-attributes.md`, que explica bitmasks em detalhe)

---

**Tamanho da janela e tamanho da tela**

- `GetScreenWidth` / `GetScreenHeight`: tamanho atual da área de desenho da janela, em pixels lógicos
- `GetRenderWidth` / `GetRenderHeight`: tamanho real do framebuffer. Difere do anterior em telas HighDPI com `FLAG_WINDOW_HIGHDPI` (no macOS Retina, o framebuffer pode ter o dobro de pixels)
- `GetMonitorWidth` / `GetMonitorHeight`: tamanho do monitor, e não da janela (ver `monitor.md`)
- Em uma janela redimensionável, o tamanho muda durante a execução. Posicione os elementos da interface com `GetScreenWidth()` em vez de usar o valor passado ao `InitWindow`

> Só pode existir uma janela por programa: o raylib guarda o estado da janela em uma variável global interna. Para várias "telas" dentro do mesmo programa, use render textures (ver `../texture/render-texture.md`) ou scissor mode (ver `../drawing/scissor-mode.md`)
