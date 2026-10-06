**Animações**

> `raylib.h` — módulo `rmodels`

O raylib reproduz animações por esqueleto (skeletal animation): o modelo tem um conjunto de ossos (bones), e cada animação guarda a pose de cada osso em cada frame. Os vértices do modelo seguem os ossos aos quais estão presos, e o modelo se deforma conforme os ossos se movem

```c
typedef struct ModelAnimation {
  int boneCount;           // quantos ossos
  int frameCount;          // quantos frames a animação tem
  BoneInfo *bones;         // nome e hierarquia dos ossos
  Transform **framePoses;  // posição/rotação/escala de cada osso em cada frame
  char name[32];           // nome da animação (ex: "Run")
} ModelAnimation;
```

```c
Model personagem = LoadModel("personagem.glb");
int n_anims = 0;
ModelAnimation *anims = LoadModelAnimations("personagem.glb", &n_anims);

int atual = 0;     // qual animação
int frame = 0;

while (!WindowShouldClose()) {
  frame = (frame + 1) % anims[atual].frameCount;
  UpdateModelAnimation(personagem, anims[atual], frame);   // aplica a pose do frame

  BeginDrawing();
  ClearBackground(RAYWHITE);
  BeginMode3D(camera);
    DrawModel(personagem, (Vector3){ 0 }, 1.0f, WHITE);
  EndMode3D();
  EndDrawing();
}

UnloadModelAnimations(anims, n_anims);
UnloadModel(personagem);
```

---

**Como funciona**

```text
esqueleto (ossos)          vértices presos aos ossos (com pesos)
   ●  cabeça                    ┌──┐
   │                            │  │ ← segue o osso da cabeça
   ●  tronco          →       ┌─┴──┴─┐
  ╱ ╲                          │      │ ← segue o tronco
 ●   ●  braços               ─┘      └─
```

- Cada vértice tem até 4 ossos que o influenciam, com pesos (`boneIds`, `boneWeights` na mesh)
- `UpdateModelAnimation` calcula a posição de cada osso no frame e move os vértices proporcionalmente aos pesos (skinning)

---

**Frames e tempo**

- O frame avança a cada chamada no exemplo acima, então a velocidade da animação depende do FPS
- Para uma velocidade fixa, calcule o frame pelo tempo: `frame = (int)(GetTime() * 30) % anims[atual].frameCount` (30 frames de animação por segundo)

---

**Armadilhas**

- A animação precisa ter o mesmo esqueleto do modelo. `IsModelAnimationValid(modelo, anim)` confere
- Formatos com animação: glTF (`.glb`/`.gltf`), IQM e M3D. OBJ não tem animação
- No raylib 5.5, o `UpdateModelAnimation` deforma os vértices na CPU (o header indica "CPU"), o que fica caro em modelos detalhados. Existe também o `UpdateModelAnimationBones`, que só atualiza as matrizes dos ossos para um shader fazer o skinning na GPU

> As animações são carregadas em um array alocado pelo raylib. Libere com `UnloadModelAnimations(array, n)`, que libera todas e o próprio array (ver `functions/unload-model-animation.md`)
