**RestoreWindow**

> `raylib.h` — módulo `rcore`

O `RestoreWindow` devolve a janela ao estado normal, tirando-a de minimizada ou de maximizada e voltando ao tamanho e posição que tinha antes

```c
void RestoreWindow(void);
```

- Não recebe parâmetros e não devolve nada
- Desfaz tanto o `MinimizeWindow` quanto o `MaximizeWindow`
- Não sai do fullscreen: para isso, use `ToggleFullscreen`

```c
if (IsKeyPressed(KEY_M)) {
  if (IsWindowMaximized()) RestoreWindow();
  else MaximizeWindow();
}
```

---

**Estados e transições**

```text
          MaximizeWindow()
normal ────────────────────► maximizada
  ▲  ◄────────────────────
  │       RestoreWindow()
  │
  │ RestoreWindow()     MinimizeWindow()
  └──────────────── minimizada ◄───── normal
```

> Sem `FLAG_WINDOW_ALWAYS_RUN`, o game loop fica parado enquanto a janela está minimizada, então o código do loop não chega a rodar para chamar o `RestoreWindow`. Para restaurar a janela pelo programa depois de um `MinimizeWindow` (por exemplo, quando um timer termina), ligue o `FLAG_WINDOW_ALWAYS_RUN`
