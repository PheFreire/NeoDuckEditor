**Matrix**

> `raymath.h` — tipo `Matrix`

Uma `Matrix` é uma matriz 4x4 de `float` que representa uma transformação no espaço 3D: translação, rotação, escala, ou qualquer combinação delas. Multiplicar um ponto pela matriz aplica a transformação. É também como a câmera e a projeção são representadas internamente

```c
typedef struct Matrix {
  float m0, m4, m8,  m12;   // primeira linha
  float m1, m5, m9,  m13;   // segunda linha
  float m2, m6, m10, m14;   // terceira linha
  float m3, m7, m11, m15;   // quarta linha
} Matrix;
```

- Os nomes dos campos seguem a convenção do OpenGL (column-major): `m12`, `m13` e `m14` guardam a translação

---

**Funções que criam matrizes**

| Função | Matriz de |
|--------|-----------|
| `MatrixIdentity()` | nenhuma transformação |
| `MatrixTranslate(x, y, z)` | mover |
| `MatrixScale(x, y, z)` | escalar |
| `MatrixRotate(eixo, ang)` | girar em torno de um eixo qualquer |
| `MatrixRotateX(ang)` / `Y` / `Z` | girar em torno de um eixo principal |
| `MatrixRotateXYZ(angulos)` | girar nos três eixos |
| `MatrixLookAt(olho, alvo, cima)` | visão de uma câmera |
| `MatrixPerspective(fovy, aspecto, perto, longe)` | projeção com perspectiva |
| `MatrixOrtho(...)` | projeção ortográfica |

---

**Combinando com MatrixMultiply**

```c
Matrix escala = MatrixScale(2, 2, 2);
Matrix rotacao = MatrixRotateY(45 * DEG2RAD);
Matrix translacao = MatrixTranslate(10, 0, 5);

// aplica: primeiro escala, depois rotação, depois translação
Matrix final = MatrixMultiply(MatrixMultiply(escala, rotacao), translacao);

Vector3 p = Vector3Transform((Vector3){ 1, 0, 0 }, final);   // aplica a um ponto
```

- No raymath, `MatrixMultiply(a, b)` resulta em uma matriz que aplica `a` **primeiro** e `b` depois
- Multiplicação de matrizes não é comutativa: trocar a ordem muda o resultado (ver `transformations.md`)

---

**Outras operações**

- `MatrixInvert(m)`: a transformação inversa (desfaz `m`). Usada para converter do mundo para o espaço local de um objeto
- `MatrixTranspose(m)`: troca linhas por colunas
- `MatrixDecompose(m, &translacao, &rotacao, &escala)`: separa uma matriz nas três partes

> Uma matriz pode guardar qualquer combinação de transformações em 16 números, e combinar matrizes custa o mesmo que combinar duas. É por isso que a GPU recebe uma única matriz `mvp` (modelo × visão × projeção) por desenho, em vez de aplicar cada transformação separadamente (ver `../concepts/transformations.md`)
