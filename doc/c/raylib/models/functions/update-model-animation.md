**UpdateModelAnimation**

> `raylib.h` — módulo `rmodels`

O `UpdateModelAnimation` aplica ao modelo a pose de um frame de uma animação, deformando os vértices de acordo com os ossos. Deve ser chamado antes de desenhar, a cada frame em que a animação avança

```c
void UpdateModelAnimation(Model model, ModelAnimation anim, int frame);
```

- `model`: o modelo (as meshes dele são alteradas)
- `anim`: a animação
- `frame`: o frame da animação, de `0` a `anim.frameCount - 1`. Valores maiores voltam ao início (são tratados com resto da divisão)

- Não devolve nada
- No raylib 5.5, a deformação dos vértices é feita na CPU e os vértices são reenviados para a GPU

```c
float tempo = 0;

while (!WindowShouldClose()) {
  tempo += GetFrameTime();
  int frame = (int)(tempo * 30.0f);   // 30 frames de animação por segundo, independente do FPS

  UpdateModelAnimation(heroi, anims[andando ? 1 : 0], frame);

  BeginDrawing();
  BeginMode3D(camera);
    DrawModel(heroi, pos, 1.0f, WHITE);
  EndMode3D();
  EndDrawing();
}
```

> A velocidade da animação deve vir do tempo, e não da quantidade de frames do jogo: avançar um frame de animação por frame de jogo faz a animação correr o dobro da velocidade a 120 FPS. Para skinning na GPU, com um shader próprio, use o `UpdateModelAnimationBones` (ver `../animations.md`)
