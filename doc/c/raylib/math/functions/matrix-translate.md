**MatrixTranslate**

> `raymath.h`

O `MatrixTranslate` cria uma matriz que move pontos por um deslocamento em `x`, `y` e `z`

```c
Matrix MatrixTranslate(float x, float y, float z);
```

- `x`, `y`, `z`: o deslocamento em cada eixo

- Devolve a matriz de translação (identidade com `x`, `y`, `z` em `m12`, `m13`, `m14`)
- Afeta pontos (com `w = 1`), e não direções

```c
DrawMesh(cubo, material, MatrixTranslate(3, 0.5f, -2));   // cubo na posição (3, 0.5, -2)

Matrix m = MatrixMultiply(MatrixRotateY(ang), MatrixTranslate(pos.x, pos.y, pos.z));
```

> Na combinação com outras transformações, a translação normalmente é a última, para que a rotação e a escala aconteçam em torno do centro do objeto (ver `matrix-multiply.md`)
