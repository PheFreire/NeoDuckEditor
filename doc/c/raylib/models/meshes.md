**Meshes**

> `raylib.h` — tipo `Mesh`

Uma mesh é a geometria de um objeto 3D: uma lista de vértices (pontos no espaço) e de triângulos formados por eles, junto com dados extras de cada vértice, como a direção da superfície (normal), a coordenada da textura e a cor. A mesh existe na RAM (arrays) e na GPU (buffers de vértices)

```c
typedef struct Mesh {
  int vertexCount;          // quantos vértices
  int triangleCount;        // quantos triângulos

  float *vertices;          // posição: x, y, z por vértice
  float *texcoords;         // coordenada de textura: u, v por vértice
  float *normals;           // normal: x, y, z por vértice
  unsigned char *colors;    // cor: r, g, b, a por vértice
  unsigned short *indices;  // quais vértices formam cada triângulo (opcional)
  /* ... tangentes, ossos, dados de animação ... */

  unsigned int vaoId;       // Vertex Array Object na GPU
  unsigned int *vboId;      // Vertex Buffer Objects na GPU
} Mesh;
```

---

**Vértices e índices**

```text
quadrado com 4 vértices e 2 triângulos

v3 ●──────● v2         vertices: [v0, v1, v2, v3]
   │    ╱ │            indices:  [0, 1, 2,   0, 2, 3]
   │  ╱   │                       triângulo 1  triângulo 2
v0 ●──────● v1
```

- Sem índices, cada triângulo precisa repetir os vértices (6 vértices para o quadrado). Com índices, os vértices compartilhados são guardados uma vez
- Cada vértice carrega todos os seus atributos: posição, normal, coordenada de textura e cor

---

**Atributos**

- **Normal**: direção perpendicular à superfície, usada para calcular a iluminação. Sem normais corretas, a luz não funciona
- **Coordenada de textura (UV)**: qual ponto da textura (de `0` a `1`) fica em cada vértice. Valores acima de `1` repetem a textura, conforme o wrap (ver `../texture/texture-wrapping.md`)
- **Cor**: cor por vértice, misturada entre os vértices de cada triângulo

---

**Gerando meshes**

| Função | Mesh |
|--------|------|
| `GenMeshPlane(largura, comprimento, divX, divZ)` | plano horizontal |
| `GenMeshCube(largura, altura, comprimento)` | caixa |
| `GenMeshSphere(raio, anéis, fatias)` | esfera |
| `GenMeshCylinder(raio, altura, fatias)` | cilindro |
| `GenMeshTorus(raio, espessura, seg, lados)` | rosca |
| `GenMeshHeightmap(img, tamanho)` | terreno a partir de uma imagem |

- As funções `GenMesh...` já enviam a mesh para a GPU (`UploadMesh`)

---

**RAM e GPU**

```text
Mesh na RAM (vertices, normals, ...)  ──UploadMesh──►  VAO + VBOs na GPU  ──►  DrawMesh
```

- A GPU desenha a partir dos VBOs. Os arrays na RAM continuam existindo e podem ser usados para colisão (`GetRayCollisionMesh`) ou para modificar a geometria e reenviar com `UpdateMeshBuffer`

> Meshes montadas à mão precisam ter os arrays alocados com `MemAlloc`/`RL_MALLOC` (o `UnloadMesh` libera com o `free` do raylib) e enviadas com `UploadMesh` antes de desenhar (ver `functions/upload-mesh.md`)
