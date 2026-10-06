**IsGestureDetected**

> `raylib.h` — módulo `rgestures`

O `IsGestureDetected` verifica se um gesto específico está acontecendo neste frame

```c
bool IsGestureDetected(unsigned int gesture);
```

- `gesture`: o gesto a verificar, como uma constante `GESTURE_*`

- Devolve `true` se o gesto atual é o pedido, e `false` caso contrário
- Gestos instantâneos (`TAP`, `DOUBLETAP`, `SWIPE_*`) são verdadeiros por um frame. Gestos contínuos (`HOLD`, `DRAG`, `PINCH_*`) são verdadeiros enquanto duram

```c
if (IsGestureDetected(GESTURE_TAP))        atirar(GetTouchPosition(0));
if (IsGestureDetected(GESTURE_DOUBLETAP))  usar_especial();
if (IsGestureDetected(GESTURE_SWIPE_UP))   pular();
if (IsGestureDetected(GESTURE_HOLD))       carregar_ataque(GetGestureHoldDuration());
```

> O sistema de gestos guarda **um** gesto atual por vez, então dois gestos não são detectados no mesmo frame. Para saber qual é o atual sem testar um por um, use o `GetGestureDetected` (ver `get-gesture-detected.md`)
