**LoadModelFromMesh**

> `raylib.h` — módulo `rmodels`

O `LoadModelFromMesh` cria um modelo a partir de uma mesh já existente, com um material padrão. É a forma de transformar uma mesh gerada (`GenMeshCube`, `GenMeshHeightmap`...) em algo que pode ser desenhado com `DrawModel`

```c
Model LoadModelFromMesh(Mesh mesh);
```

- `mesh`: a mesh, já enviada para a GPU (as funções `GenMesh...` fazem isso)

- Devolve um `Model` com uma mesh e um material padrão (shader padrão, textura branca)
- O modelo passa a ser **dono** da mesh: o `UnloadModel` libera a mesh também

```c
Model cubo = LoadModelFromMesh(GenMeshCube(1, 1, 1));
Texture2D caixote = LoadTexture("caixote.png");
cubo.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = caixote;

/* ... */

UnloadModel(cubo);        // libera a mesh junto
UnloadTexture(caixote);   // a textura é liberada separadamente
```

> Não chame `UnloadMesh` em uma mesh usada por `LoadModelFromMesh`: o `UnloadModel` já a libera, e liberar duas vezes causa erro. Se a mesma mesh for usada em vários modelos, só um deles pode liberá-la (ver `unload-model.md`)
