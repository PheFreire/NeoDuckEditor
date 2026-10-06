**GenMeshPlane**

> `raylib.h` — módulo `rmodels`

O `GenMeshPlane` gera uma mesh de um plano horizontal (no plano `XZ`), centrado na origem, com a quantidade de subdivisões escolhida

```c
Mesh GenMeshPlane(float width, float length, int resX, int resZ);
```

- `width`: tamanho em `x`
- `length`: tamanho em `z`
- `resX`, `resZ`: em quantas partes o plano é dividido em cada direção

- Devolve a `Mesh`, já enviada para a GPU, com normais apontando para cima (`+y`) e coordenadas de textura de `0` a `1`

```c
Model chao = LoadModelFromMesh(GenMeshPlane(50, 50, 1, 1));
Texture2D grama = LoadTexture("grama.png");
chao.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = grama;

DrawModel(chao, (Vector3){ 0, 0, 0 }, 1.0f, WHITE);
```

---

**Por que subdividir**

```text
resX = resZ = 1          resX = resZ = 4
┌─────────┐              ┌──┬──┬──┬──┐
│ ╲       │              ├──┼──┼──┼──┤
│   ╲     │              ├──┼──┼──┼──┤
│     ╲   │              ├──┼──┼──┼──┤
└─────────┘              └──┴──┴──┴──┘
2 triângulos             32 triângulos
```

- Para um chão plano, `1x1` basta
- Mais subdivisões são necessárias para deformar o plano depois (ondas de água, terreno) ou para iluminação calculada por vértice ficar mais suave

> Para repetir a textura várias vezes no chão (em vez de esticar uma única cópia), aumente as coordenadas de textura da mesh ou use um shader, com o wrap da textura em `REPEAT` (ver `../../texture/texture-wrapping.md`)
