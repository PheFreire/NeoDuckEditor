**UnloadMesh**

> `raylib.h` — módulo `rmodels`

O `UnloadMesh` libera uma mesh: os arrays de vértices na RAM e os buffers (VAO/VBOs) na GPU

```c
void UnloadMesh(Mesh mesh);
```

- `mesh`: a mesh a liberar

- Não devolve nada
- Só para meshes que **não** pertencem a um modelo. Meshes de um `Model` são liberadas pelo `UnloadModel`

```c
// mesh usada diretamente com DrawMesh, sem modelo
Mesh esfera = GenMeshSphere(1, 16, 16);
Material mat = LoadMaterialDefault();

BeginMode3D(camera);
  DrawMesh(esfera, mat, MatrixTranslate(0, 1, 0));
EndMode3D();

UnloadMesh(esfera);
UnloadMaterial(mat);
```

> Chamar `UnloadMesh` em uma mesh passada ao `LoadModelFromMesh` e depois `UnloadModel` libera a mesma memória duas vezes. Quando a mesh entra em um modelo, o modelo passa a ser responsável por ela (ver `load-model-from-mesh.md`)
