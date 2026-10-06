**MaximizeWindow**

> `raylib.h` — módulo `rcore`

O `MaximizeWindow` maximiza a janela, fazendo-a ocupar toda a área útil do monitor, mantendo a barra de título e as bordas. É o mesmo efeito do botão de maximizar da janela

```c
void MaximizeWindow(void);
```

- Não recebe parâmetros e não devolve nada
- Só funciona se a janela for redimensionável (`FLAG_WINDOW_RESIZABLE`). Em uma janela de tamanho fixo, não faz nada
- Depois de maximizar, o `IsWindowMaximized` devolve `true` e o `IsWindowResized` devolve `true` no frame seguinte

```c
SetConfigFlags(FLAG_WINDOW_RESIZABLE);
InitWindow(800, 450, "editor");
MaximizeWindow();   // abre já maximizada

while (!WindowShouldClose()) {
  int largura = GetScreenWidth();   // tamanho maximizado
  /* ... */
}
```

> Para voltar ao tamanho anterior, use `RestoreWindow` (ver `restore-window.md`). Para abrir a janela maximizada desde o início, também é possível usar `SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_WINDOW_MAXIMIZED)` antes do `InitWindow`
