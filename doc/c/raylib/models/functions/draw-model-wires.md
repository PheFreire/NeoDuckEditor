**DrawModelWires**

> `raylib.h` — módulo `rmodels`

O `DrawModelWires` desenha só as arestas dos triângulos de um modelo (wireframe), sem preencher as faces

```c
void DrawModelWires(Model model, Vector3 position, float scale, Color tint);
```

- `model`: o modelo
- `position`: onde a origem do modelo fica no mundo
- `scale`: escala uniforme
- `tint`: cor das linhas

- Não devolve nada
- Existe também `DrawModelWiresEx`, com os mesmos parâmetros de rotação e escala do `DrawModelEx`

```c
BeginMode3D(camera);
  DrawModel(terreno, (Vector3){ 0 }, 1.0f, WHITE);
  if (IsKeyDown(KEY_F1)) {
    DrawModelWires(terreno, (Vector3){ 0 }, 1.0f, DARKGREEN);   // mostra a malha por cima
  }
EndMode3D();
```

> O wireframe mostra quantos triângulos o modelo tem e como estão distribuídos, o que ajuda a entender problemas de iluminação, de colisão com a mesh e de desempenho em modelos detalhados demais
