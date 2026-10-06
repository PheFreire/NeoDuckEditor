**GetMouseWheelMove**

> `raylib.h` — módulo `rcore`

O `GetMouseWheelMove` devolve quanto a roda do mouse girou neste frame. É usado para zoom, rolar listas e trocar de arma

```c
float GetMouseWheelMove(void);
```

- Devolve o movimento da roda neste frame: positivo ao girar para cima (ou para longe), negativo para baixo, e `0` sem movimento
- Em mouses comuns, cada "clique" da roda vale `1.0`. Em trackpads e mouses de rolagem suave, os valores são fracionários e chegam em vários frames
- Se houver movimento horizontal e vertical, devolve o maior dos dois. Para os dois eixos separados, use `GetMouseWheelMoveV()`

```c
// zoom de uma Camera2D com a roda
float roda = GetMouseWheelMove();
if (roda != 0) {
  camera.zoom += roda * 0.1f;
  if (camera.zoom < 0.2f) camera.zoom = 0.2f;
  if (camera.zoom > 5.0f) camera.zoom = 5.0f;
}
```

---

**Zoom em direção ao cursor**

Com o zoom simples acima, a cena aumenta em direção ao `target` da câmera. Para aumentar em direção ao ponto sob o mouse:

```c
float roda = GetMouseWheelMove();
if (roda != 0) {
  Vector2 mouse_mundo = GetScreenToWorld2D(GetMousePosition(), camera);
  camera.offset = GetMousePosition();   // o ponto da tela sob o mouse vira a origem
  camera.target = mouse_mundo;          // e corresponde ao mesmo ponto do mundo
  camera.zoom *= (roda > 0) ? 1.1f : 1.0f / 1.1f;
}
```

> Multiplicar o zoom por um fator (`* 1.1`) dá uma sensação mais natural que somar (`+ 0.1`): cada clique aumenta a mesma proporção, seja o zoom pequeno ou grande
