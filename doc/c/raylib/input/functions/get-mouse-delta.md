**GetMouseDelta**

> `raylib.h` — módulo `rcore`

O `GetMouseDelta` devolve quanto o mouse se moveu desde o último frame. Em vez da posição, interessa o movimento: é o valor usado para girar câmeras, arrastar a visão de um mapa e controlar objetos pelo movimento do mouse

```c
Vector2 GetMouseDelta(void);
```

- Devolve um `Vector2` com o deslocamento em `x` e `y`, em pixels, desde o frame anterior
- `(0, 0)` quando o mouse não se moveu
- Funciona com o cursor desabilitado (`DisableCursor`), quando a posição deixa de ter significado

```c
// arrastar a visão do mapa com o botão do meio
if (IsMouseButtonDown(MOUSE_BUTTON_MIDDLE)) {
  Vector2 delta = GetMouseDelta();
  camera.target.x -= delta.x / camera.zoom;
  camera.target.y -= delta.y / camera.zoom;
}
```

---

**Câmera em primeira pessoa**

```c
DisableCursor();
float yaw = 0, pitch = 0;
const float sensibilidade = 0.003f;

while (!WindowShouldClose()) {
  Vector2 d = GetMouseDelta();
  yaw   -= d.x * sensibilidade;
  pitch -= d.y * sensibilidade;
  if (pitch >  1.5f) pitch =  1.5f;   // não deixa olhar além da vertical
  if (pitch < -1.5f) pitch = -1.5f;
  /* calcular camera.target a partir de yaw e pitch */
}
```

> O delta já é a distância percorrida em um frame, então **não** deve ser multiplicado pelo `GetFrameTime`: o mesmo movimento físico da mão gera o mesmo delta total, independente do FPS
