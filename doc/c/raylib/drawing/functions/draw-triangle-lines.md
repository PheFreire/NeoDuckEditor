**DrawTriangleLines**

> `raylib.h` — módulo `rshapes`

O `DrawTriangleLines` desenha só o contorno de um triângulo, ligando os três vértices com linhas de 1 pixel

```c
void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color);
```

- `v1`, `v2`, `v3`: os vértices
- `color`: a cor do contorno

- Não devolve nada
- O header recomenda a mesma ordem anti-horária do `DrawTriangle`, mas como são só linhas, o contorno aparece em qualquer ordem

```c
// destacar o triângulo selecionado de uma malha
DrawTriangle(t.a, t.b, t.c, Fade(SKYBLUE, 0.5f));
if (selecionado) DrawTriangleLines(t.a, t.b, t.c, BLUE);
```

> Para contornos mais grossos, desenhe três `DrawLineEx`, um para cada lado, ou um `DrawSplineLinear` fechando o caminho (repetindo o primeiro ponto no final) (ver `../splines.md`)
