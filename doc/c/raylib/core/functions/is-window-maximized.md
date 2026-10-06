**IsWindowMaximized**

> `raylib.h` — módulo `rcore`

O `IsWindowMaximized` verifica se a janela está maximizada, ou seja, ocupando toda a área útil do monitor, mas ainda com barra de título e bordas (diferente do fullscreen)

```c
bool IsWindowMaximized(void);
```

- Devolve `true` se a janela está maximizada, e `false` caso contrário
- Só faz sentido em janelas redimensionáveis (`FLAG_WINDOW_RESIZABLE`), pois o sistema não deixa maximizar uma janela de tamanho fixo

```c
SetConfigFlags(FLAG_WINDOW_RESIZABLE);
InitWindow(800, 450, "editor");

while (!WindowShouldClose()) {
  if (IsKeyPressed(KEY_M)) {
    if (IsWindowMaximized()) RestoreWindow();
    else MaximizeWindow();
  }
  /* ... */
}
```

---

**Maximizada vs fullscreen**

| | Maximizada | Fullscreen |
|---|---|---|
| Barra de título e bordas | sim | não |
| Barra de tarefas / dock | visível | escondida |
| Muda a resolução do monitor | não | pode mudar |
| Função | `MaximizeWindow` | `ToggleFullscreen` |
| Verificação | `IsWindowMaximized` | `IsWindowFullscreen` |

> Quando a janela é maximizada, o tamanho muda: o `IsWindowResized` devolve `true` naquele frame e o `GetScreenWidth`/`GetScreenHeight` passam a devolver o novo tamanho (ver `is-window-resized.md`)
