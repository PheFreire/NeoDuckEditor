**GetTouchPointCount**

> `raylib.h` — módulo `rcore`

O `GetTouchPointCount` devolve quantos dedos estão tocando a tela neste frame

```c
int GetTouchPointCount(void);
```

- Devolve a quantidade de pontos de toque ativos, de `0` até o máximo suportado pelo raylib (`MAX_TOUCH_POINTS`, 8 por padrão)
- Em computadores sem tela sensível ao toque, devolve `0`

```c
int dedos = GetTouchPointCount();

if (dedos == 1) {
  mover_camera(GetTouchPosition(0));
} else if (dedos == 2) {
  Vector2 a = GetTouchPosition(0);
  Vector2 b = GetTouchPosition(1);
  float distancia = Vector2Distance(a, b);   // usada para calcular o zoom
  /* ... */
}
```

> Para pinça e outros movimentos com dois dedos, o sistema de gestos já calcula os valores (`GESTURE_PINCH_IN`, `GetGesturePinchVector`), sem precisar acompanhar os toques manualmente (ver `../gestures.md`)
