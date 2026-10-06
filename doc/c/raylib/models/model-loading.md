**Carregando modelos**

> `raylib.h` — módulo `rmodels`

Modelos podem ser carregados de arquivos 3D exportados por programas como Blender, ou montados a partir de meshes geradas pelo próprio raylib. Em ambos os casos, a geometria é enviada para a GPU e as texturas dos materiais são carregadas

| Função | Cria o modelo a partir de |
|--------|---------------------------|
| `LoadModel(arquivo)` | um arquivo 3D |
| `LoadModelFromMesh(mesh)` | uma mesh gerada ou montada pelo programa |
| `GenMeshCube`, `GenMeshSphere`, `GenMeshPlane`, `GenMeshCylinder`, `GenMeshTorus`... | meshes prontas para o `LoadModelFromMesh` |
| `GenMeshHeightmap(img, tamanho)` | terreno a partir de uma imagem em tons de cinza |
| `GenMeshCubicmap(img, tamanho)` | labirinto de cubos a partir de uma imagem |

```c
Model nave = LoadModel("modelos/nave.glb");
if (!IsModelValid(nave)) {
  TraceLog(LOG_ERROR, "não carregou a nave");
}

Model chao = LoadModelFromMesh(GenMeshPlane(20, 20, 1, 1));   // plano de 20x20 sem arquivo
```

---

**Formatos**

| Formato | Extensão | Observação |
|---------|----------|------------|
| Wavefront OBJ | `.obj` (+ `.mtl`) | simples, só geometria e materiais |
| glTF 2.0 | `.gltf`, `.glb` | formato moderno, com materiais PBR e animação |
| IQM | `.iqm` | modelos com animação por esqueleto |
| MagicaVoxel | `.vox` | modelos de voxels |
| Model 3D | `.m3d` | formato compacto com animação |

- glTF (`.glb`, binário em um único arquivo) é a escolha mais completa para exportar do Blender
- Texturas referenciadas pelo arquivo são procuradas a partir da pasta do modelo

---

**Terreno a partir de uma imagem**

```c
Image mapa_altura = LoadImage("terreno.png");   // tons de cinza: preto = baixo, branco = alto
Mesh terreno = GenMeshHeightmap(mapa_altura, (Vector3){ 64, 8, 64 });   // 64x64 de área, 8 de altura máxima
Model modelo = LoadModelFromMesh(terreno);

Texture2D grama = LoadTexture("grama.png");
modelo.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = grama;
UnloadImage(mapa_altura);
```

> Um modelo carregado precisa de um `UnloadModel`, que libera as meshes e a lista de materiais. As texturas e os shaders atribuídos aos materiais **não** são liberados por ele, pois podem ser compartilhados entre modelos: libere-os separadamente (ver `functions/unload-model.md`)
