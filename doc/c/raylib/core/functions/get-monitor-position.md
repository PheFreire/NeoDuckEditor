**GetMonitorPosition**

> `raylib.h` — módulo `rcore`

O `GetMonitorPosition` devolve a posição do canto superior esquerdo de um monitor na área de trabalho. Com vários monitores, cada um ocupa uma região diferente de uma mesma área de coordenadas

```c
Vector2 GetMonitorPosition(int monitor);
```

- `monitor`: índice do monitor, de `0` a `GetMonitorCount() - 1`

- Devolve um `Vector2` com `x` e `y` do canto superior esquerdo do monitor, em pixels
- O monitor principal costuma estar em `(0, 0)`. Os outros podem ter coordenadas positivas ou **negativas** (um monitor à esquerda do principal tem `x` negativo)

```c
// centralizar a janela em um monitor específico
void centralizar_em(int m) {
  Vector2 origem = GetMonitorPosition(m);
  int x = (int)origem.x + (GetMonitorWidth(m)  - GetScreenWidth())  / 2;
  int y = (int)origem.y + (GetMonitorHeight(m) - GetScreenHeight()) / 2;
  SetWindowPosition(x, y);
}
```

---

**Exemplo de layout**

```text
       x = -1280                  x = 0                    x = 1920
       ┌──────────────┐           ┌──────────────────────┐ ┌──────────────┐
       │ monitor 2    │           │ monitor 0 (principal)│ │ monitor 1    │
       │ 1280x1024    │           │ 1920x1080            │ │ 2560x1440    │
       └──────────────┘           └──────────────────────┘ └──────────────┘
GetMonitorPosition(2) = (-1280, 0)  (0, 0)                  (1920, 0)
```

> A posição é dada pelo sistema operacional e reflete o arranjo configurado pelo usuário nas preferências de tela. O `SetWindowPosition` usa essas mesmas coordenadas (ver `set-window-position.md`)
