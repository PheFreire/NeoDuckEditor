**SetMaterialTexture**

> `raylib.h` — módulo `rmodels`

O `SetMaterialTexture` define a textura de um map de um material, como a textura difusa (a cor da superfície) ou o mapa de normais

```c
void SetMaterialTexture(Material *material, int mapType, Texture2D texture);
```

- `material`: ponteiro para o material
- `mapType`: qual map: `MATERIAL_MAP_DIFFUSE`, `MATERIAL_MAP_NORMAL`, `MATERIAL_MAP_SPECULAR`...
- `texture`: a textura

- Não devolve nada
- Equivale a `material->maps[mapType].texture = texture`

```c
Model barril = LoadModelFromMesh(GenMeshCylinder(0.5f, 1.2f, 16));
Texture2D madeira = LoadTexture("madeira.png");

SetMaterialTexture(&barril.materials[0], MATERIAL_MAP_DIFFUSE, madeira);
```

> A textura não é copiada: o material passa a apontar para a mesma textura (pelo `id`). A mesma textura pode ser usada em vários materiais, e deve ser liberada uma única vez, depois que todos deixarem de usá-la (ver `../materials.md`)
