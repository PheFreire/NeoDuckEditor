**DisableCursor**

> `raylib.h` — módulo `rcore`

O `DisableCursor` esconde o cursor e o trava na janela. O mouse deixa de ter uma posição útil na tela e passa a funcionar como um controle de movimento relativo, lido com `GetMouseDelta`. É o modo usado por câmeras em primeira pessoa

```c
void DisableCursor(void);
```

- Não recebe parâmetros e não devolve nada
- O cursor fica invisível e não sai da janela, mesmo com movimentos grandes
- O `GetMousePosition` passa a devolver uma posição virtual sem limites. O que importa é o `GetMouseDelta`, quanto o mouse andou desde o último frame

```c
Camera3D camera = {
  .position = { 0, 2, 4 },
  .target   = { 0, 2, 0 },
  .up       = { 0, 1, 0 },
  .fovy     = 60,
  .projection = CAMERA_PERSPECTIVE,
};

DisableCursor();

while (!WindowShouldClose()) {
  UpdateCamera(&camera, CAMERA_FIRST_PERSON);   // usa o GetMouseDelta para girar
  /* ... */
}
```

---

**O que acontece por baixo**

- No desktop, o raylib usa o modo `GLFW_CURSOR_DISABLED` do GLFW, que esconde o cursor e o recentraliza internamente, entregando só o movimento relativo
- Em sistemas que suportam, o movimento cru (raw mouse motion) é usado, sem a aceleração do sistema operacional, o que deixa a mira mais precisa

> Para sair desse modo, use `EnableCursor`, e não `ShowCursor`: o `ShowCursor` só desfaz o `HideCursor` (ver `enable-cursor.md`)
