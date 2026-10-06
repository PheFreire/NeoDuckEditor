**GetCurrentMonitor**

> `raylib.h` — módulo `rcore`

O `GetCurrentMonitor` devolve o índice do monitor onde a janela está. É usado junto com as outras funções de monitor para consultar o tamanho e a taxa de atualização da tela em que o jogo está sendo mostrado

```c
int GetCurrentMonitor(void);
```

- Devolve o índice do monitor atual, de `0` a `GetMonitorCount() - 1`
- Se a janela estiver entre dois monitores, devolve o que contém a maior parte dela (ou o centro dela, dependendo da plataforma)

```c
int m = GetCurrentMonitor();
SetTargetFPS(GetMonitorRefreshRate(m));   // FPS igual à taxa do monitor atual
```

---

**Atualizando quando a janela muda de monitor**

```c
int monitor_anterior = GetCurrentMonitor();

while (!WindowShouldClose()) {
  int m = GetCurrentMonitor();
  if (m != monitor_anterior) {
    SetTargetFPS(GetMonitorRefreshRate(m));   // monitor de 60 Hz para outro de 144 Hz
    monitor_anterior = m;
  }
  /* ... */
}
```

> Em fullscreen, a janela fica presa ao monitor em que entrou nesse modo. Para jogar em outro monitor, mova a janela com `SetWindowMonitor` antes de chamar o `ToggleFullscreen`
