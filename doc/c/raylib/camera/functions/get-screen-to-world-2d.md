**GetScreenToWorld2D**

> `raylib.h` — módulo `rcore`

O `GetScreenToWorld2D` converte uma posição da tela para a posição correspondente no mundo, desfazendo o deslocamento, a rotação e o zoom de uma `Camera2D`. É usado para saber em qual ponto do mundo o mouse está

```c
Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera);
```

- `position`: a posição na tela (por exemplo, `GetMousePosition()`)
- `camera`: a câmera usada para desenhar o mundo

- Devolve a posição correspondente no mundo

```c
Vector2 mouse_mundo = GetScreenToWorld2D(GetMousePosition(), camera);

// selecionar a unidade sob o cursor
for (int i = 0; i < n; i++) {
  if (CheckCollisionPointCircle(mouse_mundo, unidades[i].pos, unidades[i].raio)) {
    hover = i;
  }
}

// desenhar o cursor dentro do mundo
BeginMode2D(camera);
  DrawCircleLinesV(mouse_mundo, 10, RED);
EndMode2D();
```

> Internamente, a função calcula a inversa da matriz da câmera e a aplica ao ponto. É o caminho inverso do `GetWorldToScreen2D` (ver `get-world-to-screen-2d.md` e `../coordinate-conversion.md`)
