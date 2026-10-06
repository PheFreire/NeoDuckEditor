**DrawModel**

> `raylib.h` — módulo `rmodels`

O `DrawModel` desenha um modelo 3D em uma posição do mundo, com uma escala uniforme e uma cor de tint

```c
void DrawModel(Model model, Vector3 position, float scale, Color tint);
```

- `model`: o modelo
- `position`: onde a origem do modelo fica no mundo
- `scale`: escala igual nos três eixos (`1.0` = tamanho original)
- `tint`: cor que multiplica as cores do material (`WHITE` para não alterar)

- Não devolve nada
- Precisa estar entre `BeginMode3D` e `EndMode3D`
- Aplica a `model.transform` antes da escala e da posição

```c
BeginMode3D(camera);
  for (int i = 0; i < n_arvores; i++) {
    DrawModel(arvore, arvores[i].pos, arvores[i].escala, WHITE);
  }
  DrawModel(casa, (Vector3){ 5, 0, 5 }, 1.0f, selecionada ? YELLOW : WHITE);
EndMode3D();
```

> O `DrawModel` não tem rotação. Para girar, use o `DrawModelEx` ou altere a `model.transform` (ver `draw-model-ex.md` e `../transformations.md`)
