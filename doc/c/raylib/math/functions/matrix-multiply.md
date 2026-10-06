**MatrixMultiply**

> `raymath.h`

O `MatrixMultiply` combina duas matrizes de transformação em uma só. O resultado aplica a transformação de `left` primeiro e a de `right` depois

```c
Matrix MatrixMultiply(Matrix left, Matrix right);
```

- `left`: a transformação aplicada primeiro
- `right`: a transformação aplicada depois

- Devolve a matriz combinada

```c
Matrix escala     = MatrixScale(2, 2, 2);
Matrix rotacao    = MatrixRotateY(90 * DEG2RAD);
Matrix translacao = MatrixTranslate(10, 0, 5);

Matrix m = MatrixMultiply(MatrixMultiply(escala, rotacao), translacao);
Vector3 p = Vector3Transform((Vector3){ 1, 0, 0 }, m);
// (1,0,0) → escala (2,0,0) → rotação (0,0,-2) → translação (10,0,3)
```

---

**A ordem muda o resultado**

```c
Matrix a = MatrixMultiply(MatrixRotateY(ang), MatrixTranslate(5, 0, 0));   // gira no lugar, depois move
Matrix b = MatrixMultiply(MatrixTranslate(5, 0, 0), MatrixRotateY(ang));   // move, depois gira em torno da origem
```

- `a`: o objeto fica em `(5, 0, 0)`, girado no próprio eixo
- `b`: o objeto orbita a origem a 5 unidades de distância

> A ordem padrão para posicionar objetos é escala, rotação e translação (ver `../transformations.md`)
