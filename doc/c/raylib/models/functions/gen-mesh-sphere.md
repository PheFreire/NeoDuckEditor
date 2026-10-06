**GenMeshSphere**

> `raylib.h` — módulo `rmodels`

O `GenMeshSphere` gera a mesh de uma esfera centrada na origem, dividida em anéis (horizontais) e fatias (verticais)

```c
Mesh GenMeshSphere(float radius, int rings, int slices);
```

- `radius`: o raio
- `rings`: quantos anéis horizontais (resolução de cima para baixo)
- `slices`: quantas fatias verticais (resolução ao redor)

- Devolve a `Mesh`, já enviada para a GPU, com normais e coordenadas de textura

```c
Model planeta = LoadModelFromMesh(GenMeshSphere(2.0f, 32, 32));
planeta.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = LoadTexture("terra.png");

DrawModelEx(planeta, (Vector3){ 0 }, (Vector3){ 0, 1, 0 }, GetTime() * 10, (Vector3){ 1, 1, 1 }, WHITE);
```

---

**Resolução**

```text
rings = slices = 8        rings = slices = 32
facetada, poucos          suave, mais
triângulos (~128)         triângulos (~2000)
```

- Valores maiores deixam a esfera mais redonda, mas com mais triângulos
- Para objetos pequenos ou distantes, `16` costuma bastar. Para planetas em primeiro plano, `32` a `64`

> Uma textura mapeada em uma esfera fica esticada nos polos, pois o mapeamento é como o de um mapa-múndi (equiretangular). Texturas feitas para esse formato (como mapas da Terra) se encaixam corretamente
