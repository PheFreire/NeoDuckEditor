**IsMouseButtonDown**

> `raylib.h` — módulo `rcore`

O `IsMouseButtonDown` verifica se um botão do mouse está apertado agora. Devolve `true` em todos os frames enquanto o botão está segurado, e é usado para ações contínuas: pintar, arrastar, tiro automático

```c
bool IsMouseButtonDown(int button);
```

- `button`: o botão: `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT`, `MOUSE_BUTTON_MIDDLE`, etc

- Devolve `true` enquanto o botão está apertado, e `false` enquanto está solto

```c
// programa de desenho: pinta enquanto segura o botão
RenderTexture2D tela = LoadRenderTexture(800, 450);

while (!WindowShouldClose()) {
  if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
    BeginTextureMode(tela);
    DrawCircleV(GetMousePosition(), 8, BLACK);
    EndTextureMode();
  }
  /* desenhar tela.texture */
}
```

> Entre um frame e outro, o mouse pode andar muitos pixels. Desenhar um círculo por frame deixa buracos em movimentos rápidos: ligue a posição anterior à atual com `DrawLineEx` para um traço contínuo
