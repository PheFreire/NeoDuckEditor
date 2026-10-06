**Mouse**

> `raylib.h` — módulo `rcore`

O raylib lê a posição do cursor, o movimento desde o último frame, os botões e a roda do mouse. A posição é dada em pixels, nas coordenadas da janela, com `(0, 0)` no canto superior esquerdo

```c
Vector2 mouse = GetMousePosition();
Rectangle botao = { 300, 200, 200, 50 };

bool sobre = CheckCollisionPointRec(mouse, botao);
if (sobre && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
  iniciar_jogo();
}

DrawRectangleRec(botao, sobre ? SKYBLUE : LIGHTGRAY);
```

---

**Funções**

| Função | Devolve |
|--------|---------|
| `IsMouseButtonPressed(b)` / `Down` / `Released` / `Up` | estado do botão `b` (ver `input.md`) |
| `GetMouseX()` / `GetMouseY()` | posição em `int` |
| `GetMousePosition()` | posição em `Vector2` |
| `GetMouseDelta()` | quanto o mouse se moveu desde o último frame |
| `SetMousePosition(x, y)` | move o cursor |
| `GetMouseWheelMove()` | movimento da roda neste frame |
| `GetMouseWheelMoveV()` | movimento da roda em `x` e `y` (trackpads) |

- Botões: `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT`, `MOUSE_BUTTON_MIDDLE` (clique na roda) e, em mouses com mais botões, `MOUSE_BUTTON_SIDE`, `MOUSE_BUTTON_EXTRA`, `MOUSE_BUTTON_FORWARD`, `MOUSE_BUTTON_BACK`

---

**Posição na tela vs posição no mundo**

```text
GetMousePosition()  →  coordenadas da janela (tela)
        │
        │  GetScreenToWorld2D(mouse, camera)
        ▼
posição no mundo do jogo (considerando o movimento, zoom e rotação da câmera)
```

- Com uma `Camera2D`, o ponto da tela onde o mouse está não é o mesmo ponto do mundo. Para clicar em objetos do mundo, converta a posição (ver `../camera/coordinate-conversion.md`)
- Elementos de interface desenhados fora do `BeginMode2D` usam a posição da tela diretamente

---

**Arrastar um objeto**

```c
bool arrastando = false;
Vector2 deslocamento = { 0 };

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT) && CheckCollisionPointRec(GetMousePosition(), caixa)) {
  arrastando = true;
  deslocamento = (Vector2){ GetMouseX() - caixa.x, GetMouseY() - caixa.y };
}
if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT)) {
  arrastando = false;
}
if (arrastando) {
  caixa.x = GetMouseX() - deslocamento.x;
  caixa.y = GetMouseY() - deslocamento.y;
}
```

- O `deslocamento` guarda onde a caixa foi agarrada, para ela não "pular" com o canto para a ponta do cursor

> Para câmeras em primeira pessoa, a posição não importa, só o movimento: use `DisableCursor` e `GetMouseDelta` (ver `../core/cursor.md` e `functions/get-mouse-delta.md`)
