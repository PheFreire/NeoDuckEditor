**MinimizeWindow**

> `raylib.h` — módulo `rcore`

O `MinimizeWindow` minimiza (iconifica) a janela, escondendo-a na barra de tarefas ou no dock, de onde o usuário pode restaurá-la

```c
void MinimizeWindow(void);
```

- Não recebe parâmetros e não devolve nada
- Depois de minimizar, o `IsWindowMinimized` devolve `true`
- Sem a flag `FLAG_WINDOW_ALWAYS_RUN`, o game loop **para** enquanto a janela está minimizada, e só continua quando ela é restaurada (ver `is-window-minimized.md`)

```c
if (IsKeyPressed(KEY_F9)) {
  MinimizeWindow();   // "boss key": esconde o jogo rapidamente
}
```

> Para trazer a janela de volta pelo programa, use `RestoreWindow`. Se a intenção é tirar a janela da tela sem que ela apareça na barra de tarefas, use `SetWindowState(FLAG_WINDOW_HIDDEN)` (ver `is-window-hidden.md`)
