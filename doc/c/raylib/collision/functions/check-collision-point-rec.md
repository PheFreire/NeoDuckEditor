**CheckCollisionPointRec**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionPointRec` verifica se um ponto está dentro de um retângulo. É a função usada para saber se o mouse está sobre um botão ou um elemento da interface

```c
bool CheckCollisionPointRec(Vector2 point, Rectangle rec);
```

- `point`: o ponto
- `rec`: o retângulo

- Devolve `true` se o ponto está dentro do retângulo
- As bordas esquerda e superior contam como dentro, e as bordas direita e inferior não

```c
Rectangle botoes[] = {
  { 300, 150, 200, 50 },   // jogar
  { 300, 220, 200, 50 },   // opções
  { 300, 290, 200, 50 },   // sair
};
const char *textos[] = { "JOGAR", "OPÇÕES", "SAIR" };

Vector2 mouse = GetMousePosition();
for (int i = 0; i < 3; i++) {
  bool sobre = CheckCollisionPointRec(mouse, botoes[i]);
  DrawRectangleRec(botoes[i], sobre ? SKYBLUE : LIGHTGRAY);
  DrawText(textos[i], botoes[i].x + 20, botoes[i].y + 12, 24, DARKBLUE);
  if (sobre && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) escolher(i);
}
```

> A posição do mouse está em coordenadas da tela. Para testar objetos do mundo com uma câmera ativa, converta antes com `GetScreenToWorld2D` (ver `../../camera/coordinate-conversion.md`)
