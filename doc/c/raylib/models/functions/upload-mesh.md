**UploadMesh**

> `raylib.h` — módulo `rmodels`

O `UploadMesh` envia os arrays de vértices de uma mesh (posições, normais, coordenadas de textura, cores, índices) para a GPU, criando o VAO e os VBOs que a GPU usa para desenhar

```c
void UploadMesh(Mesh *mesh, bool dynamic);
```

- `mesh`: ponteiro para a mesh (os campos `vaoId` e `vboId` são preenchidos)
- `dynamic`: `true` se os vértices vão mudar com frequência (avisa a GPU para otimizar para atualizações), `false` para geometria fixa

- Não devolve nada
- As funções `GenMesh...` e o `LoadModel` já chamam o `UploadMesh`. Só é necessário para meshes montadas à mão

```c
// triângulo montado à mão
Mesh m = { 0 };
m.vertexCount = 3;
m.triangleCount = 1;
m.vertices  = (float *)MemAlloc(3 * 3 * sizeof(float));
m.normals   = (float *)MemAlloc(3 * 3 * sizeof(float));
m.texcoords = (float *)MemAlloc(3 * 2 * sizeof(float));

float v[] = { 0, 0, 0,   1, 0, 2,   2, 0, 0 };   // anti-horário visto de cima
float n[] = { 0, 1, 0,   0, 1, 0,   0, 1, 0 };   // normais para cima
float t[] = { 0, 0,      0.5f, 1,   1, 0 };
memcpy(m.vertices, v, sizeof(v));
memcpy(m.normals, n, sizeof(n));
memcpy(m.texcoords, t, sizeof(t));

UploadMesh(&m, false);
Model tri = LoadModelFromMesh(m);
```

- Use `MemAlloc` (o alocador do raylib) para os arrays, pois o `UnloadMesh` os libera com o `MemFree` correspondente

> Depois do envio, alterar os arrays na RAM não muda o que é desenhado. Para atualizar os vértices de uma mesh dinâmica, use `UpdateMeshBuffer`, que reenvia só o buffer alterado (ver `../meshes.md`)
