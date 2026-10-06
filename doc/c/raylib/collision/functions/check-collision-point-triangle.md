**CheckCollisionPointTriangle**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionPointTriangle` verifica se um ponto está dentro de um triângulo definido por três vértices

```c
bool CheckCollisionPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3);
```

- `point`: o ponto
- `p1`, `p2`, `p3`: os vértices do triângulo, em qualquer ordem

- Devolve `true` se o ponto está dentro do triângulo

```c
// clicar em uma nave triangular
Vector2 a = { nave.x, nave.y - 20 };
Vector2 b = { nave.x - 12, nave.y + 12 };
Vector2 c = { nave.x + 12, nave.y + 12 };

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT) &&
    CheckCollisionPointTriangle(GetMousePosition(), a, b, c)) {
  selecionar(nave);
}
```

---

**Como funciona**

- O teste calcula as coordenadas baricêntricas do ponto: quanto ele "pertence" a cada vértice. Se as três forem positivas, o ponto está dentro
- Ao contrário do `DrawTriangle`, a ordem dos vértices não importa

> Para polígonos com mais lados, use o `CheckCollisionPointPoly(point, points, pointCount)`, que funciona com qualquer polígono, inclusive côncavo (ver `../point-collision.md`)
