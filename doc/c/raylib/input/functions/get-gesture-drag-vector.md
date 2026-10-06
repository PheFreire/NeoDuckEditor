**GetGestureDragVector**

> `raylib.h` — módulo `rgestures`

O `GetGestureDragVector` devolve o deslocamento de um gesto de arrastar (`GESTURE_DRAG`): para onde e o quanto o dedo (ou o mouse) se moveu durante o arraste

```c
Vector2 GetGestureDragVector(void);
```

- Devolve um `Vector2` com o deslocamento do arraste. O sistema de gestos trabalha com posições **normalizadas pelo tamanho da tela** (de `0` a `1`), então o vetor também está nessa escala
- Só tem significado enquanto o gesto atual é `GESTURE_DRAG`

```c
// mostra a direção do arraste com uma seta a partir do centro da tela
if (IsGestureDetected(GESTURE_DRAG)) {
  Vector2 d = GetGestureDragVector();
  Vector2 centro = { GetScreenWidth() / 2.0f, GetScreenHeight() / 2.0f };
  Vector2 ponta = { centro.x + d.x * GetScreenWidth(), centro.y + d.y * GetScreenHeight() };
  DrawLineEx(centro, ponta, 4, RED);
}
```

- Multiplicar pela largura e pela altura da tela converte o valor normalizado para pixels

> Para arrastes que precisam de precisão em pixels a cada frame, também é possível usar o `GetMouseDelta`, já que o primeiro toque é reportado como mouse (ver `get-mouse-delta.md`). O `GetGestureDragAngle` complementa o vetor com o ângulo do arraste
