**HideCursor**

> `raylib.h` — módulo `rcore`

O `HideCursor` esconde o cursor do mouse quando ele está sobre a janela. O mouse continua funcionando normalmente: a posição é atualizada e o cursor pode sair da janela, onde volta a aparecer

```c
void HideCursor(void);
```

- Não recebe parâmetros e não devolve nada
- O `GetMousePosition` continua devolvendo a posição real do cursor
- Para mostrar de novo, use `ShowCursor`

```c
HideCursor();

while (!WindowShouldClose()) {
  Vector2 mouse = GetMousePosition();

  BeginDrawing();
  ClearBackground(RAYWHITE);
  DrawCircleLines((int)mouse.x, (int)mouse.y, 10, RED);   // mira desenhada pelo jogo
  DrawLine((int)mouse.x - 15, (int)mouse.y, (int)mouse.x + 15, (int)mouse.y, RED);
  DrawLine((int)mouse.x, (int)mouse.y - 15, (int)mouse.x, (int)mouse.y + 15, RED);
  EndDrawing();
}
```

> Se a intenção é usar o mouse para girar uma câmera, o `HideCursor` não basta: o cursor ainda sai da janela e para nas bordas da tela. Para isso, use o `DisableCursor`, que trava o cursor (ver `disable-cursor.md`)
