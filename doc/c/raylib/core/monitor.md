**Monitor**

> `raylib.h` — módulo `rcore`

As funções de monitor consultam os monitores conectados: quantos existem, em qual deles a janela está, a posição de cada um na área de trabalho, o tamanho, a taxa de atualização e o nome. São usadas para abrir a janela centralizada, escolher a resolução do fullscreen e ajustar o FPS ao monitor

```c
InitWindow(800, 450, "monitor");

int monitor = GetCurrentMonitor();
TraceLog(LOG_INFO, "%s: %dx%d @ %d Hz",
         GetMonitorName(monitor),
         GetMonitorWidth(monitor),
         GetMonitorHeight(monitor),
         GetMonitorRefreshRate(monitor));
```

---

**Funções**

| Função | Devolve |
|--------|---------|
| `GetMonitorCount()` | quantidade de monitores conectados |
| `GetCurrentMonitor()` | índice do monitor onde a janela está |
| `GetMonitorPosition(m)` | posição do canto superior esquerdo do monitor `m` na área de trabalho |
| `GetMonitorWidth(m)` / `GetMonitorHeight(m)` | resolução atual do monitor `m`, em pixels |
| `GetMonitorRefreshRate(m)` | taxa de atualização do monitor `m`, em Hz |
| `GetMonitorName(m)` | nome legível do monitor `m`, em UTF-8 |

- O índice `m` vai de `0` a `GetMonitorCount() - 1`. O monitor principal é normalmente o `0`
- Todas precisam da janela criada: chamadas antes do `InitWindow` devolvem `0` ou valores vazios

---

**A área de trabalho com vários monitores**

```text
GetMonitorPosition(0) = (0, 0)       GetMonitorPosition(1) = (1920, 0)
┌──────────────────────┐┌──────────────────────┐
│ monitor 0            ││ monitor 1            │
│ 1920 x 1080          ││ 2560 x 1440          │
│        ┌──────┐      ││                      │
│        │janela│      ││                      │
│        └──────┘      ││                      │
└──────────────────────┘└──────────────────────┘
```

- Os monitores formam uma única área de coordenadas. A posição da janela (`SetWindowPosition`) é dada nessas coordenadas globais
- Para colocar a janela em outro monitor, some a posição dele: `SetWindowPosition(pos.x + 100, pos.y + 100)`

---

**Usos comuns**

Centralizar a janela no monitor atual:

```c
int m = GetCurrentMonitor();
Vector2 origem = GetMonitorPosition(m);
int x = (int)origem.x + (GetMonitorWidth(m) - GetScreenWidth()) / 2;
int y = (int)origem.y + (GetMonitorHeight(m) - GetScreenHeight()) / 2;
SetWindowPosition(x, y);
```

Usar a taxa do monitor como FPS alvo:

```c
SetTargetFPS(GetMonitorRefreshRate(GetCurrentMonitor()));
```

Janela no tamanho do monitor:

```c
int m = GetCurrentMonitor();
SetWindowSize(GetMonitorWidth(m), GetMonitorHeight(m));
```

> Os valores de largura, altura e taxa são do **modo de vídeo atual** do monitor, ou seja, o que o sistema está usando agora, e não a resolução máxima que ele suporta. Em telas HighDPI, a largura e a altura podem estar em pixels lógicos, e não físicos
