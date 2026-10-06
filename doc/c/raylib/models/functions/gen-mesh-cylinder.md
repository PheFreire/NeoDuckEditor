**GenMeshCylinder**

> `raylib.h` — módulo `rmodels`

O `GenMeshCylinder` gera a mesh de um cilindro vertical, com a base no plano `y = 0` e o topo em `y = altura`

```c
Mesh GenMeshCylinder(float radius, float height, int slices);
```

- `radius`: o raio
- `height`: a altura
- `slices`: quantas fatias ao redor (resolução)

- Devolve a `Mesh`, já enviada para a GPU, com as tampas de cima e de baixo
- A base fica na origem: um cilindro posicionado em `y = 0` fica apoiado no chão

```c
Model coluna = LoadModelFromMesh(GenMeshCylinder(0.4f, 4.0f, 24));
coluna.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = LoadTexture("marmore.png");

for (int i = 0; i < 6; i++) {
  DrawModel(coluna, (Vector3){ i * 3.0f, 0, 0 }, 1.0f, WHITE);
}
```

> Para um cone ou um cilindro com raios diferentes em cima e embaixo, existe o `GenMeshCone(raio, altura, fatias)`. Para desenhar sem gerar mesh, `DrawCylinder(pos, raio_topo, raio_base, altura, fatias, cor)` aceita os dois raios
