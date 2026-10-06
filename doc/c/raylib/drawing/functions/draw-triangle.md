**DrawTriangle**

> `raylib.h` — módulo `rshapes`

O `DrawTriangle` desenha um triângulo preenchido a partir de três vértices

```c
void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3, Color color);
```

- `v1`, `v2`, `v3`: os vértices, em sentido **anti-horário** na tela
- `color`: a cor de preenchimento

- Não devolve nada
- Com os vértices em sentido horário, o triângulo pode não aparecer, pois a GPU descarta faces "de costas" (back-face culling)

```c
// nave apontando para cima
Vector2 ponta     = { nave.x,      nave.y - 20 };
Vector2 esquerda  = { nave.x - 12, nave.y + 12 };
Vector2 direita   = { nave.x + 12, nave.y + 12 };
DrawTriangle(ponta, esquerda, direita, SKYBLUE);   // ponta → esquerda → direita: anti-horário
```

---

**Rotacionando os vértices**

```c
Vector2 rotacionar(Vector2 p, Vector2 centro, float angulo) {
  float s = sinf(angulo), c = cosf(angulo);
  Vector2 d = { p.x - centro.x, p.y - centro.y };
  return (Vector2){ centro.x + d.x * c - d.y * s, centro.y + d.x * s + d.y * c };
}

float a = nave.angulo;
DrawTriangle(rotacionar(ponta, nave, a), rotacionar(esquerda, nave, a),
             rotacionar(direita, nave, a), SKYBLUE);
```

- Rotacionar os três vértices pelo mesmo ângulo mantém a ordem, e o triângulo continua visível. O raymath tem `Vector2Rotate` para isso (ver `../../math/vector2.md`)

> Se um triângulo não aparece, a causa mais comum é a ordem dos vértices. Trocar dois deles (por exemplo, `v2` com `v3`) inverte o sentido (ver `../triangles.md`)
