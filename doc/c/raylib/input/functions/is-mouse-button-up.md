**IsMouseButtonUp**

> `raylib.h` — módulo `rcore`

O `IsMouseButtonUp` verifica se um botão do mouse **não** está apertado. É o contrário exato do `IsMouseButtonDown`

```c
bool IsMouseButtonUp(int button);
```

- `button`: o botão: `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT`, `MOUSE_BUTTON_MIDDLE`, etc

- Devolve `true` enquanto o botão está solto, e `false` enquanto está apertado
- `IsMouseButtonUp(b)` é sempre igual a `!IsMouseButtonDown(b)`

```c
// destaca o botão só quando o mouse está em cima e não está clicando
bool sobre = CheckCollisionPointRec(GetMousePosition(), botao);
Color cor = LIGHTGRAY;
if (sobre && IsMouseButtonUp(MOUSE_BUTTON_LEFT))   cor = SKYBLUE;   // hover
if (sobre && IsMouseButtonDown(MOUSE_BUTTON_LEFT)) cor = BLUE;      // pressionado
DrawRectangleRec(botao, cor);
```

> Os três estados visuais de um botão de interface (normal, hover, pressionado) são obtidos com a colisão do mouse e o `IsMouseButtonUp`/`IsMouseButtonDown`, sem precisar de nenhuma biblioteca de interface
