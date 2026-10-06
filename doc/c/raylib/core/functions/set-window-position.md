**SetWindowPosition**

> `raylib.h` — módulo `rcore`

O `SetWindowPosition` move a janela para uma posição da área de trabalho. A posição é a do canto superior esquerdo da janela, em pixels, nas coordenadas globais de todos os monitores

```c
void SetWindowPosition(int x, int y);
```

- `x`: posição horizontal do canto superior esquerdo da janela
- `y`: posição vertical do canto superior esquerdo da janela

- Não devolve nada
- A posição atual é lida com `GetWindowPosition()`, que devolve um `Vector2`
- Não tem efeito em fullscreen

```c
// centralizar a janela no monitor atual
int m = GetCurrentMonitor();
Vector2 origem = GetMonitorPosition(m);
SetWindowPosition((int)origem.x + (GetMonitorWidth(m) - GetScreenWidth()) / 2,
                  (int)origem.y + (GetMonitorHeight(m) - GetScreenHeight()) / 2);
```

---

**Coordenadas da área de trabalho**

```text
(0, 0) ────────────────────────────► x
  │  monitor 0                monitor 1 começa em x = 1920
  │      (x, y)
  │        ┌───────────┐
  │        │  janela   │
  ▼        └───────────┘
  y
```

- Com vários monitores, cada um tem uma posição na área de trabalho (ver `../monitor.md`). Para colocar a janela em outro monitor, some a posição dele
- Em alguns sistemas, `y` pode ser a posição da área de desenho, e não da barra de título. A barra pode ficar fora da tela se `y` for `0`

> O raylib 5.5 já abre a janela centralizada no monitor principal. Chame o `SetWindowPosition` só se quiser outra posição, como lembrar onde o usuário deixou a janela na última execução
