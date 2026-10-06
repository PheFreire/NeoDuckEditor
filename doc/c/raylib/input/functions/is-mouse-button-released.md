**IsMouseButtonReleased**

> `raylib.h` — módulo `rcore`

O `IsMouseButtonReleased` verifica se um botão do mouse foi solto **neste frame**. Devolve `true` uma vez, no frame em que o botão passou de apertado para solto, e é usado para terminar ações de arrastar e confirmar cliques de interface

```c
bool IsMouseButtonReleased(int button);
```

- `button`: o botão: `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT`, `MOUSE_BUTTON_MIDDLE`, etc

- Devolve `true` no frame em que o botão foi solto, e `false` nos outros

```c
// estilingue: puxa segurando e solta para lançar
static Vector2 inicio;

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) inicio = GetMousePosition();
if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT)) {
  Vector2 fim = GetMousePosition();
  Vector2 forca = Vector2Subtract(inicio, fim);   // direção oposta ao puxão
  lancar(Vector2Scale(forca, 5.0f));
}
```

> Se o botão for solto fora da janela, alguns sistemas não entregam o evento. Em ações de arrastar, trate também o caso de o cursor sair da janela (`IsCursorOnScreen`) para não deixar o objeto "grudado" no mouse
