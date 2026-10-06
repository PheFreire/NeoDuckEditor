**SetWindowState**

> `raylib.h` — módulo `rcore`

O `SetWindowState` liga uma ou mais flags de configuração da janela **depois** que ela já existe. É a forma de mudar o comportamento da janela durante a execução: torná-la redimensionável, sempre no topo, sem borda, escondida, etc

```c
void SetWindowState(unsigned int flags);
```

- `flags`: uma ou mais `ConfigFlags` combinadas com `|`, como `FLAG_WINDOW_RESIZABLE | FLAG_WINDOW_TOPMOST`

- Não devolve nada
- Liga as flags pedidas e mantém as outras como estavam
- Para desligar, use `ClearWindowState` (ver `clear-window-state.md`)
- Para verificar uma flag, use `IsWindowState(flag)`

```c
InitWindow(800, 450, "jogo");

SetWindowState(FLAG_WINDOW_RESIZABLE);              // agora pode ser redimensionada
SetWindowState(FLAG_WINDOW_TOPMOST);                 // sempre acima das outras
SetWindowState(FLAG_VSYNC_HINT);                     // liga o V-Sync

if (IsWindowState(FLAG_WINDOW_TOPMOST)) {
  DrawText("sempre no topo", 10, 10, 20, GRAY);
}
```

---

**SetConfigFlags vs SetWindowState**

| | `SetConfigFlags` | `SetWindowState` |
|---|---|---|
| Quando | antes do `InitWindow` | depois do `InitWindow` |
| Efeito | configura como a janela será criada | altera a janela existente |
| Flags de contexto (`FLAG_MSAA_4X_HINT`, `FLAG_WINDOW_TRANSPARENT`, `FLAG_WINDOW_HIGHDPI`) | funcionam | não têm efeito |

- Flags que dependem da criação do contexto OpenGL só podem ser definidas antes da janela existir
- Flags de comportamento (redimensionável, topmost, escondida, V-Sync, fullscreen) podem ser trocadas a qualquer momento

> Usar o `SetWindowState` com `FLAG_FULLSCREEN_MODE` equivale a entrar em fullscreen, e com `FLAG_WINDOW_MAXIMIZED` a maximizar. Para alternar entre os estados, as funções `ToggleFullscreen`, `MaximizeWindow` e `RestoreWindow` são mais legíveis
