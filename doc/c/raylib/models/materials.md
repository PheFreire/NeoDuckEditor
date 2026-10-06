**Materiais**

> `raylib.h` — tipo `Material`

Um material define a aparência de uma mesh: qual shader calcula a cor final de cada pixel e quais texturas e cores ele usa (os **maps**). O mesmo formato de mesh pode parecer madeira, metal ou pedra apenas trocando o material

```c
typedef struct MaterialMap {
  Texture2D texture;   // textura do map
  Color color;         // cor do map
  float value;         // valor numérico (intensidade, rugosidade...)
} MaterialMap;

typedef struct Material {
  Shader shader;       // o programa que roda na GPU
  MaterialMap *maps;   // array de maps (MATERIAL_MAP_DIFFUSE, NORMAL, ...)
  float params[4];     // parâmetros genéricos
} Material;
```

---

**Maps**

| Map | Uso |
|-----|-----|
| `MATERIAL_MAP_DIFFUSE` (`ALBEDO`) | a cor/textura principal da superfície |
| `MATERIAL_MAP_SPECULAR` (`METALNESS`) | brilho / metalicidade |
| `MATERIAL_MAP_NORMAL` | relevo fino, simulado pela iluminação |
| `MATERIAL_MAP_ROUGHNESS` | rugosidade (PBR) |
| `MATERIAL_MAP_OCCLUSION` | sombreamento de cantos |
| `MATERIAL_MAP_EMISSION` | partes que emitem luz |
| `MATERIAL_MAP_HEIGHT` | mapa de altura |
| `MATERIAL_MAP_CUBEMAP`, `IRRADIANCE`, `PREFILTER`, `BRDF` | iluminação baseada em imagem |

- O shader padrão do raylib usa só o map **difuso** (textura e cor). Os outros maps só têm efeito com um shader próprio que os leia (ver `../shaders/shaders.md`)

---

**Trocando a textura de um modelo**

```c
Model caixa = LoadModelFromMesh(GenMeshCube(1, 1, 1));
Texture2D madeira = LoadTexture("madeira.png");

SetMaterialTexture(&caixa.materials[0], MATERIAL_MAP_DIFFUSE, madeira);
// o mesmo que: caixa.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = madeira;

caixa.materials[0].maps[MATERIAL_MAP_DIFFUSE].color = BEIGE;   // cor multiplicada pela textura
```

---

**Materiais, meshes e modelos**

- `model.materials[]`: os materiais do modelo
- `model.meshMaterial[i]`: o índice do material usado pela mesh `i`
- `SetModelMeshMaterial(&modelo, mesh, material)`: troca o material de uma mesh
- `LoadMaterials(arquivo, &n)`: carrega os materiais de um arquivo (como um `.mtl`) sem a geometria
- `LoadMaterialDefault()`: material com o shader padrão e uma textura branca, base para montar materiais à mão

> Texturas e shaders podem ser compartilhados por vários materiais e modelos. Por isso o `UnloadModel` não os libera: o programa decide quando cada textura deixa de ser usada e chama o `UnloadTexture`
