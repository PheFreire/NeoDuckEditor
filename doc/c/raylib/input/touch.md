**Touch**

> `raylib.h` — módulo `rcore`

As funções de touch leem os dedos sobre uma tela sensível ao toque, em celulares, tablets e notebooks com touchscreen. Cada dedo é um **ponto de toque**, com uma posição na tela e um índice

```c
int dedos = GetTouchPointCount();

for (int i = 0; i < dedos; i++) {
  Vector2 p = GetTouchPosition(i);
  DrawCircleV(p, 30, Fade(ORANGE, 0.5f));
  DrawText(TextFormat("%d", i), (int)p.x - 5, (int)p.y - 10, 20, BLACK);
}
```

---

**Funções**

| Função | Devolve |
|--------|---------|
| `GetTouchPointCount()` | quantos dedos estão tocando a tela agora |
| `GetTouchPosition(i)` | posição do ponto de toque `i` |
| `GetTouchX()` / `GetTouchY()` | posição do ponto `0` |
| `GetTouchPointId(i)` | identificador único do ponto `i` |

- O índice `i` vai de `0` a `GetTouchPointCount() - 1`
- Os índices não são estáveis: se o primeiro dedo sair, o segundo pode virar o índice `0`. Para seguir o mesmo dedo entre frames, use o `GetTouchPointId`

---

**Touch e mouse**

- Em plataformas com toque, o primeiro toque também é reportado como mouse: `IsMouseButtonDown(MOUSE_BUTTON_LEFT)` e `GetMousePosition` funcionam com um dedo
- Isso permite que uma interface feita para mouse funcione no celular sem mudanças, desde que só use um toque por vez
- No desktop sem touchscreen, `GetTouchPointCount()` devolve `0`

> Para reconhecer movimentos como tocar, arrastar, deslizar ou fazer pinça, use o sistema de gestos, que interpreta a sequência de toques por você (ver `gestures.md`)
