**BeginMode3D**

> `raylib.h` — módulo `rcore`

O `BeginMode3D` ativa uma câmera 3D: tudo que for desenhado até o `EndMode3D` é posicionado em uma cena 3D e projetado na tela de acordo com a posição, a direção e a projeção da câmera

```c
void BeginMode3D(Camera3D camera);
```

- `camera`: a câmera, com `position`, `target`, `up`, `fovy` e `projection`

- Não devolve nada
- Deve ser chamado dentro de `BeginDrawing`/`EndDrawing` (ou de `BeginTextureMode`)
- Liga o teste de profundidade (depth test): objetos mais próximos cobrem os mais distantes, independente da ordem de desenho

```c
Camera3D cam = {
  .position = { 6, 6, 6 }, .target = { 0, 0, 0 }, .up = { 0, 1, 0 },
  .fovy = 45, .projection = CAMERA_PERSPECTIVE,
};

BeginDrawing();
ClearBackground(RAYWHITE);

BeginMode3D(cam);
  DrawCube((Vector3){ 0, 0.5f, 0 }, 1, 1, 1, RED);
  DrawCubeWires((Vector3){ 0, 0.5f, 0 }, 1, 1, 1, MAROON);
  DrawGrid(10, 1);
EndMode3D();

DrawText("cena 3D", 10, 10, 20, DARKGRAY);   // texto 2D por cima
EndDrawing();
```

---

**O que acontece por baixo**

```text
BeginMode3D(camera)
  │  calcula a matriz de projeção (perspectiva ou ortográfica, a partir de fovy e da proporção da tela)
  ▼
  │  calcula a matriz de visão (LookAt: position → target, com up)
  ▼
  │  liga o depth test
  ▼
Draw3D...()   cada vértice: projeção × visão × modelo × posição
  ▼
EndMode3D()   volta às matrizes 2D e desliga o depth test
```

- Os planos de corte (objetos muito perto ou muito longe não aparecem) são definidos pelo raylib, com valores padrão de `0.01` a `1000` unidades

> Diferente do 2D, no modo 3D a ordem de desenho não define quem fica na frente para objetos opacos: o depth buffer resolve isso por pixel. Objetos transparentes são a exceção e devem ser desenhados por último, do mais distante para o mais próximo (ver `../camera-3d.md`)
