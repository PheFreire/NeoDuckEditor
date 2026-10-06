**GetModelBoundingBox**

> `raylib.h` — módulo `rmodels`

O `GetModelBoundingBox` calcula a menor caixa alinhada aos eixos que contém todos os vértices de todas as meshes de um modelo

```c
BoundingBox GetModelBoundingBox(Model model);
```

- `model`: o modelo

- Devolve a `BoundingBox`, com os cantos `min` e `max`
- Considera a `model.transform`, mas não a posição, a rotação ou a escala passadas ao `DrawModel`
- Percorre todos os vértices: calcule uma vez, e não todo frame

```c
Model carro = LoadModel("carro.glb");
BoundingBox local = GetModelBoundingBox(carro);

// apoiar o modelo no chão: deslocar para que o ponto mais baixo fique em y = 0
float ajuste_y = -local.min.y;
DrawModel(carro, (Vector3){ x, ajuste_y, z }, 1.0f, WHITE);
```

> Para colidir com outros objetos, desloque a caixa pela posição do objeto antes de testar (ver `../bounding-box.md` e `../../collision/functions/check-collision-boxes.md`)
