**Transformações de modelos**

> `raylib.h` — módulos `rmodels` e `raymath`

Para colocar um modelo no mundo, os vértices dele (definidos em torno da origem do próprio modelo) são transformados por **escala**, **rotação** e **translação**. Essas três operações são combinadas em uma matriz 4x4, que a GPU aplica a cada vértice

```text
espaço do modelo  ──(escala → rotação → translação)──►  espaço do mundo  ──(câmera)──►  tela
```

---

**Pelos parâmetros do DrawModelEx**

```c
DrawModelEx(nave,
            (Vector3){ 10, 2, -5 },     // translação: onde fica no mundo
            (Vector3){ 0, 1, 0 },       // eixo de rotação: y (girar como um pião)
            angulo,                      // ângulo em graus
            (Vector3){ 1, 1, 1 },       // escala em cada eixo
            WHITE);
```

- Suficiente para objetos que giram em torno de um único eixo
- Para combinações de rotações (inclinar e girar ao mesmo tempo), use a matriz do modelo

---

**Pela matriz model.transform**

```c
// rotação acumulada em vários eixos (avião: pitch, yaw e roll)
nave.transform = MatrixRotateXYZ((Vector3){ pitch * DEG2RAD, yaw * DEG2RAD, roll * DEG2RAD });
DrawModel(nave, nave_pos, 1.0f, WHITE);   // a posição e a escala ainda vêm dos parâmetros
```

- O `DrawModel` combina `model.transform` com a translação, a rotação e a escala passadas
- As funções de matriz (`MatrixRotateXYZ`, `MatrixTranslate`, `MatrixScale`, `MatrixMultiply`) vêm do `raymath.h` (ver `../math/matrix.md`)

---

**A ordem importa**

```text
escala → rotação → translação   (correto: gira no lugar e depois vai para a posição)
translação → rotação            (gira em torno da ORIGEM do mundo, como um planeta em órbita)
```

```c
Matrix m = MatrixMultiply(MatrixMultiply(MatrixScale(2, 2, 2),
                                         MatrixRotateY(angulo * DEG2RAD)),
                          MatrixTranslate(pos.x, pos.y, pos.z));
DrawMesh(mesh, material, m);
```

- No raymath, `MatrixMultiply(a, b)` aplica `a` primeiro e `b` depois. Por isso a escala vem no começo e a translação no final

> A origem do modelo (definida no programa 3D que o criou) é o ponto em torno do qual ele gira e escala. Um modelo com a origem nos pés gira em torno dos pés. Se o modelo gira "torto", provavelmente a origem está fora do centro (ver `../concepts/transformations.md`)
