**GetMonitorHeight**

> `raylib.h` — módulo `rcore`

O `GetMonitorHeight` devolve a altura de um monitor, em pixels, de acordo com o modo de vídeo que ele está usando agora. É o par do `GetMonitorWidth`

```c
int GetMonitorHeight(int monitor);
```

- `monitor`: índice do monitor, de `0` a `GetMonitorCount() - 1`

- Devolve a altura atual do monitor, em pixels, incluindo a área ocupada pela barra de tarefas ou pelo dock
- Um índice inválido gera um aviso no log e devolve `0`

```c
// fullscreen na resolução nativa do monitor
int m = GetCurrentMonitor();
SetWindowSize(GetMonitorWidth(m), GetMonitorHeight(m));
ToggleFullscreen();
```

> A altura do monitor é maior que a altura útil para uma janela, pois inclui a barra de tarefas e, no macOS, a barra de menu. Uma janela com essa altura em modo janela pode ficar parcialmente escondida. Para ocupar a área útil, use o `MaximizeWindow`
