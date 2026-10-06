**GenMeshCube**

> `raylib.h` — módulo `rmodels`

O `GenMeshCube` gera a mesh de uma caixa (cuboide) centrada na origem, com largura, altura e comprimento escolhidos

```c
Mesh GenMeshCube(float width, float height, float length);
```

- `width`: tamanho em `x`
- `height`: tamanho em `y`
- `length`: tamanho em `z`

- Devolve a `Mesh`, já enviada para a GPU
- Cada face tem os seus próprios 4 vértices (24 no total), para que as normais e as coordenadas de textura sejam corretas em cada lado

```c
Model caixote = LoadModelFromMesh(GenMeshCube(1, 1, 1));
caixote.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = LoadTexture("caixote.png");

DrawModel(caixote, (Vector3){ 0, 0.5f, 0 }, 1.0f, WHITE);   // y = 0.5: apoiado no chão
```

---

**GenMeshCube vs DrawCube**

| | `GenMeshCube` + `DrawModel` | `DrawCube` |
|---|---|---|
| Textura | sim | não, só cor |
| Iluminação/shader próprio | sim, pelo material | só o shader padrão |
| Geometria | gerada uma vez, reutilizada | gerada a cada chamada |
| Uso | objetos do jogo | protótipos e depuração |

> A caixa é centrada na origem, então a metade dela fica abaixo de `y = 0`. Para apoiar no chão, posicione em `y = altura / 2`
