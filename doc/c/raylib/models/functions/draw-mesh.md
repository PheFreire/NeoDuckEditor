**DrawMesh**

> `raylib.h` — módulo `rmodels`

O `DrawMesh` desenha uma mesh com um material e uma matriz de transformação. É a função de baixo nível que o `DrawModel` usa para cada mesh do modelo, e dá controle total sobre a transformação

```c
void DrawMesh(Mesh mesh, Material material, Matrix transform);
```

- `mesh`: a mesh (já enviada para a GPU)
- `material`: o material (shader, texturas e cores)
- `transform`: a matriz que leva os vértices do espaço da mesh para o mundo

- Não devolve nada
- Precisa estar entre `BeginMode3D` e `EndMode3D`

```c
Mesh cubo = GenMeshCube(1, 1, 1);
Material mat = LoadMaterialDefault();
mat.maps[MATERIAL_MAP_DIFFUSE].color = RED;

// escala → rotação → translação
Matrix m = MatrixMultiply(MatrixMultiply(MatrixScale(1, 2, 1),
                                         MatrixRotateY(GetTime())),
                          MatrixTranslate(3, 1, 0));

BeginMode3D(camera);
  DrawMesh(cubo, mat, m);
EndMode3D();
```

> Com o `DrawMesh`, a mesma mesh pode ser desenhada com materiais diferentes sem criar vários modelos. Para muitas cópias da mesma mesh, o `DrawMeshInstanced` envia todas as matrizes de uma vez (ver `../model-drawing.md` e `../transformations.md`)
