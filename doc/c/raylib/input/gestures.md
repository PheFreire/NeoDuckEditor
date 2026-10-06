**Gestos**

> `raylib.h` — módulo `rgestures` (dentro do `rcore`)

O sistema de gestos interpreta a sequência de toques (ou cliques do mouse) e reconhece movimentos comuns de telas sensíveis ao toque: tocar, tocar duas vezes, segurar, arrastar, deslizar em uma direção e fazer pinça para zoom

```c
SetGesturesEnabled(GESTURE_TAP | GESTURE_DRAG | GESTURE_SWIPE_LEFT | GESTURE_SWIPE_RIGHT);

while (!WindowShouldClose()) {
  if (IsGestureDetected(GESTURE_TAP))         selecionar(GetTouchPosition(0));
  if (IsGestureDetected(GESTURE_SWIPE_LEFT))  proxima_pagina();
  if (IsGestureDetected(GESTURE_SWIPE_RIGHT)) pagina_anterior();
  if (IsGestureDetected(GESTURE_DRAG))        mover_mapa(GetGestureDragVector());
  /* ... */
}
```

---

**Gestos**

| Constante | Valor | Gesto |
|-----------|-------|-------|
| `GESTURE_NONE` | 0 | nenhum |
| `GESTURE_TAP` | 1 | toque rápido |
| `GESTURE_DOUBLETAP` | 2 | dois toques rápidos |
| `GESTURE_HOLD` | 4 | segurar o dedo parado |
| `GESTURE_DRAG` | 8 | arrastar segurando |
| `GESTURE_SWIPE_RIGHT` / `LEFT` / `UP` / `DOWN` | 16 / 32 / 64 / 128 | deslizar rápido em uma direção |
| `GESTURE_PINCH_IN` / `PINCH_OUT` | 256 / 512 | dois dedos se aproximando / afastando |

- Cada gesto é um bit diferente, por isso podem ser combinados com `|` no `SetGesturesEnabled`

---

**Funções**

| Função | Devolve |
|--------|---------|
| `SetGesturesEnabled(flags)` | define quais gestos serão reconhecidos |
| `IsGestureDetected(g)` | `true` se o gesto `g` está acontecendo neste frame |
| `GetGestureDetected()` | o último gesto detectado |
| `GetGestureDragVector()` | o deslocamento do arraste |
| `GetGestureHoldDuration()` | há quanto tempo o dedo está parado (segundos) |
| `GetGestureDragAngle()` | ângulo do arraste |
| `GetGesturePinchVector()` / `GetGesturePinchAngle()` | variação e ângulo da pinça |

---

**Gestos com mouse**

- No desktop, o botão esquerdo do mouse funciona como um dedo: clicar é `GESTURE_TAP`, arrastar com o botão apertado é `GESTURE_DRAG`, e um arraste rápido vira `GESTURE_SWIPE_*`
- Pinça precisa de dois toques simultâneos, então só funciona em telas sensíveis ao toque

> Habilitar só os gestos usados evita falsos positivos: com todos ligados, um arraste curto pode ser reconhecido como swipe, e um toque demorado como hold. Por padrão, todos estão habilitados
