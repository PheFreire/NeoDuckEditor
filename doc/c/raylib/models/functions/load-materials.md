**LoadMaterials**

> `raylib.h` — módulo `rmodels`

O `LoadMaterials` carrega só os materiais de um arquivo de modelo (como um `.mtl` do formato OBJ), sem carregar a geometria

```c
Material *LoadMaterials(const char *fileName, int *materialCount);
```

- `fileName`: o arquivo com os materiais
- `materialCount`: ponteiro onde é escrito quantos materiais foram carregados

- Devolve um array de `Material` alocado pelo raylib
- Cada material vem com o shader padrão e as texturas referenciadas no arquivo

```c
int n = 0;
Material *mats = LoadMaterials("cenario.mtl", &n);

// aplicar o material de um arquivo a uma mesh gerada
Model parede = LoadModelFromMesh(GenMeshCube(4, 3, 0.2f));
parede.materials[0] = mats[0];

/* ... */

for (int i = 1; i < n; i++) UnloadMaterial(mats[i]);   // os não usados
MemFree(mats);
```

> O array e os materiais são responsabilidade do programa. Cada material é liberado com `UnloadMaterial`, e o array com `MemFree`. Cuidado para não liberar um material que foi copiado para um modelo e ainda está em uso (ver `unload-material.md`)
