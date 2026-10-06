**Bounding box**

> `raylib.h` — tipo `BoundingBox`

Uma bounding box é a menor caixa alinhada aos eixos que contém todos os vértices de um modelo ou mesh. É uma aproximação simples da forma do objeto, usada para colisões rápidas, seleção com o mouse e para decidir se o objeto está visível

```c
typedef struct BoundingBox {
  Vector3 min;   // canto com os menores x, y, z
  Vector3 max;   // canto com os maiores x, y, z
} BoundingBox;

BoundingBox GetModelBoundingBox(Model model);
BoundingBox GetMeshBoundingBox(Mesh mesh);
void DrawBoundingBox(BoundingBox box, Color color);
```

```c
Model carro = LoadModel("carro.glb");
BoundingBox caixa_local = GetModelBoundingBox(carro);   // calcule uma vez, depois de carregar

Vector3 tamanho = Vector3Subtract(caixa_local.max, caixa_local.min);
TraceLog(LOG_INFO, "carro: %.2f x %.2f x %.2f", tamanho.x, tamanho.y, tamanho.z);
```

---

**Espaço local vs mundo**

```text
caixa calculada (espaço do modelo)      caixa no mundo
min = (-1, 0, -2)                        min = posição + (-1, 0, -2)
max = ( 1, 1.5, 2)                       max = posição + ( 1, 1.5, 2)
```

- O `GetModelBoundingBox` considera os vértices na posição original do arquivo (e a `model.transform`), e **não** a posição passada ao `DrawModel`
- Para colidir na cena, desloque a caixa pela posição do objeto:

```c
BoundingBox caixa_mundo = {
  Vector3Add(caixa_local.min, pos_carro),
  Vector3Add(caixa_local.max, pos_carro),
};

if (CheckCollisionBoxes(caixa_mundo, caixa_parede)) { /* ... */ }

BeginMode3D(camera);
  DrawModel(carro, pos_carro, 1.0f, WHITE);
  DrawBoundingBox(caixa_mundo, LIME);   // depuração: a caixa deve envolver o modelo
EndMode3D();
```

---

**Rotação e escala**

- A caixa é sempre alinhada aos eixos. Um objeto girado 45 graus precisa de uma caixa maior para continuar contido nela
- Com escala, multiplique `min` e `max` pela escala antes de somar a posição
- Para objetos que giram muito, uma esfera (centro e raio) costuma ser uma aproximação melhor (ver `../collision/collision-3d.md`)

> O cálculo percorre todos os vértices do modelo, então não é para ser feito todo frame. Calcule a caixa local uma vez depois de carregar e só desloque pela posição a cada frame
