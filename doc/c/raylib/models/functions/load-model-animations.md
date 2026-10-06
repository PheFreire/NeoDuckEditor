**LoadModelAnimations**

> `raylib.h` — módulo `rmodels`

O `LoadModelAnimations` carrega todas as animações de um arquivo de modelo (glTF, IQM ou M3D). Cada animação guarda a pose de cada osso em cada frame

```c
ModelAnimation *LoadModelAnimations(const char *fileName, int *animCount);
```

- `fileName`: o arquivo com as animações (pode ser o mesmo arquivo do modelo)
- `animCount`: ponteiro onde é escrito quantas animações foram carregadas

- Devolve um array de `ModelAnimation` alocado pelo raylib, ou `NULL` se não houver animações
- Cada animação tem `frameCount` frames, `boneCount` ossos e um `name`

```c
Model heroi = LoadModel("heroi.glb");
int n = 0;
ModelAnimation *anims = LoadModelAnimations("heroi.glb", &n);

for (int i = 0; i < n; i++) {
  TraceLog(LOG_INFO, "animação %d: %s (%d frames)", i, anims[i].name, anims[i].frameCount);
}
// animação 0: Idle (60 frames)
// animação 1: Run (24 frames)
```

> O esqueleto das animações precisa ser o mesmo do modelo. Confira com `IsModelAnimationValid(modelo, anims[i])` antes de usar uma animação vinda de outro arquivo (ver `../animations.md`)
