**GetTouchPosition**

> `raylib.h` — módulo `rcore`

O `GetTouchPosition` devolve a posição de um dedo sobre a tela sensível ao toque, em pixels da janela

```c
Vector2 GetTouchPosition(int index);
```

- `index`: índice do ponto de toque, de `0` a `GetTouchPointCount() - 1`

- Devolve um `Vector2` com a posição do toque, nas mesmas coordenadas do mouse
- Para um índice sem toque ativo, o valor não tem significado: confira antes com `GetTouchPointCount`

```c
// joystick virtual: o primeiro toque na metade esquerda da tela controla o movimento
for (int i = 0; i < GetTouchPointCount(); i++) {
  Vector2 t = GetTouchPosition(i);
  if (t.x < GetScreenWidth() / 2.0f) {
    Vector2 dir = Vector2Normalize(Vector2Subtract(t, centro_joystick));
    pos.x += dir.x * 200 * dt;
    pos.y += dir.y * 200 * dt;
  }
}
```

> Os índices são reorganizados quando um dedo sai da tela. Para seguir o mesmo dedo entre frames (por exemplo, em um arraste), guarde o identificador devolvido por `GetTouchPointId(index)` e procure por ele a cada frame (ver `../touch.md`)
