**Cursor**

> `raylib.h` — módulo `rcore`

As funções de cursor controlam o ponteiro do mouse dentro da janela: mostrar, esconder, travar no centro (para câmeras em primeira pessoa) e trocar o formato. Elas não alteram a leitura do mouse, que continua funcionando pelas funções de input (ver `../input/mouse.md`)

| Função | Efeito |
|--------|--------|
| `ShowCursor()` | mostra o cursor |
| `HideCursor()` | esconde o cursor, mas ele continua se movendo e saindo da janela |
| `IsCursorHidden()` | `true` se o cursor está escondido |
| `EnableCursor()` | destrava o cursor e o mostra de novo |
| `DisableCursor()` | esconde o cursor e o trava na janela (modo "captura") |
| `IsCursorOnScreen()` | `true` se o cursor está dentro da janela |
| `SetMouseCursor(cursor)` | troca o formato: seta, mão, texto, redimensionar... |

---

**Esconder vs desabilitar**

```text
HideCursor()                       DisableCursor()
─────────────                      ───────────────
cursor invisível                   cursor invisível
posição livre                      preso à janela
pode sair da janela                não sai da janela
GetMousePosition: posição real     GetMousePosition: posição virtual, sem limite
uso: cursor desenhado pelo jogo    uso: câmera em primeira pessoa (GetMouseDelta)
```

- Com `HideCursor`, o jogo normalmente desenha a própria mira ou ponteiro na posição do mouse
- Com `DisableCursor`, o mouse vira um controle de rotação: o que importa é o quanto ele se moveu (`GetMouseDelta`), e não onde está

```c
DisableCursor();   // ao entrar no jogo

while (!WindowShouldClose()) {
  Vector2 delta = GetMouseDelta();
  angulo_x += delta.x * 0.003f;
  angulo_y += delta.y * 0.003f;

  if (IsKeyPressed(KEY_TAB)) {
    if (IsCursorHidden()) EnableCursor();   // abre um menu, libera o mouse
    else DisableCursor();
  }
  /* ... */
}
```

---

**Formato do cursor**

```c
SetMouseCursor(MOUSE_CURSOR_POINTING_HAND);   // ao passar sobre um botão
SetMouseCursor(MOUSE_CURSOR_DEFAULT);         // ao sair
```

- Formatos disponíveis: `MOUSE_CURSOR_DEFAULT`, `MOUSE_CURSOR_ARROW`, `MOUSE_CURSOR_IBEAM` (texto), `MOUSE_CURSOR_CROSSHAIR`, `MOUSE_CURSOR_POINTING_HAND`, `MOUSE_CURSOR_RESIZE_EW`, `MOUSE_CURSOR_RESIZE_NS`, `MOUSE_CURSOR_RESIZE_ALL`, `MOUSE_CURSOR_NOT_ALLOWED`, entre outros
- O formato é desenhado pelo sistema operacional, e a aparência exata varia entre Linux, macOS e Windows

> O `UpdateCamera` em modos como `CAMERA_FIRST_PERSON` só lê o `GetMouseDelta`, ele não trava o cursor sozinho. Quem chama o `DisableCursor` é o programa, normalmente uma vez antes do game loop, e é isso que impede o mouse de sair da janela enquanto a câmera gira (ver `../camera/functions/update-camera.md`)
