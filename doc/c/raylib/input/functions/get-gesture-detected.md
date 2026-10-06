**GetGestureDetected**

> `raylib.h` — módulo `rgestures`

O `GetGestureDetected` devolve o gesto que está acontecendo agora, como um valor `GESTURE_*`

```c
int GetGestureDetected(void);
```

- Devolve o gesto atual (`GESTURE_TAP`, `GESTURE_DRAG`, etc), ou `GESTURE_NONE` (`0`) quando nenhum está acontecendo

```c
const char *nome_gesto(int g) {
  switch (g) {
    case GESTURE_TAP:         return "TAP";
    case GESTURE_DOUBLETAP:   return "DOUBLE TAP";
    case GESTURE_HOLD:        return "HOLD";
    case GESTURE_DRAG:        return "DRAG";
    case GESTURE_SWIPE_RIGHT: return "SWIPE RIGHT";
    case GESTURE_SWIPE_LEFT:  return "SWIPE LEFT";
    case GESTURE_SWIPE_UP:    return "SWIPE UP";
    case GESTURE_SWIPE_DOWN:  return "SWIPE DOWN";
    case GESTURE_PINCH_IN:    return "PINCH IN";
    case GESTURE_PINCH_OUT:   return "PINCH OUT";
    default:                  return "NENHUM";
  }
}

DrawText(nome_gesto(GetGestureDetected()), 10, 10, 20, DARKGRAY);
```

> Como o retorno é um único valor, ele combina bem com um `switch` (ver `../../../control_flow/switch.md`). Para reagir a um gesto específico dentro de uma condição, o `IsGestureDetected` é mais direto
