**SetShaderValueMatrix**

> `raylib.h` — módulo `rcore`

O `SetShaderValueMatrix` envia uma matriz 4x4 para um uniform `mat4` do shader

```c
void SetShaderValueMatrix(Shader shader, int locIndex, Matrix mat);
```

- `shader`: o shader
- `locIndex`: a location do uniform `mat4`
- `mat`: a matriz

- Não devolve nada

```c
// matriz da "câmera da luz", usada para calcular sombras
Matrix luz_view = MatrixLookAt(pos_luz, (Vector3){ 0 }, (Vector3){ 0, 1, 0 });
Matrix luz_proj = MatrixOrtho(-10, 10, -10, 10, 0.1, 50);
Matrix luz_vp = MatrixMultiply(luz_view, luz_proj);

SetShaderValueMatrix(sombra, GetShaderLocation(sombra, "lightVP"), luz_vp);
```

> As matrizes que o raylib já envia sozinho (`mvp`, `matModel`, `matView`, `matProjection`) não precisam desta função. Ela serve para matrizes próprias, como transformações de luz e de efeitos (ver `../../math/matrix.md`)
