**models**

> `raylib.h` — módulo `rmodels`

O módulo de modelos carrega, gera e desenha objetos 3D. Um `Model` junta uma ou mais **meshes** (a geometria: vértices e triângulos) com **materiais** (a aparência: texturas, cores e shader), e pode ter um esqueleto para animação. Também inclui formas 3D prontas, como cubos, esferas e planos

```c
Camera3D cam = { { 4, 4, 4 }, { 0, 0, 0 }, { 0, 1, 0 }, 45, CAMERA_PERSPECTIVE };
Model casa = LoadModel("casa.obj");

BeginDrawing();
ClearBackground(SKYBLUE);
BeginMode3D(cam);
  DrawModel(casa, (Vector3){ 0, 0, 0 }, 1.0f, WHITE);
  DrawCube((Vector3){ 3, 0.5f, 0 }, 1, 1, 1, RED);   // forma pronta, sem modelo
  DrawGrid(10, 1);
EndMode3D();
EndDrawing();

UnloadModel(casa);
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| carregar modelos de arquivo ou de meshes | `model-loading.md` |
| desenhar modelos | `model-drawing.md` |
| meshes: vértices, índices, VBOs | `meshes.md` |
| materiais e texturas | `materials.md` |
| posição, rotação e escala | `transformations.md` |
| animação por esqueleto | `animations.md` |
| bounding box | `bounding-box.md` |

- Cada função tem sua nota em `functions/`

---

**Como um Model é composto**

```text
Model
├── transform          matriz local (posição, rotação, escala base)
├── meshes[]           geometria
│     └── Mesh: vertices, normals, texcoords, indices ... (+ VAO/VBO na GPU)
├── materials[]        aparência
│     └── Material: shader + maps[] (difusa, normal, specular...) com textura e cor
├── meshMaterial[]     qual material cada mesh usa
└── bones / bindPose   esqueleto, para animação
```

- Um modelo de carro pode ter uma mesh para a carroceria, outra para as rodas e outra para os vidros, cada uma com o seu material

---

**Formas prontas**

| Função | Desenha |
|--------|---------|
| `DrawCube(pos, w, h, l, cor)` / `DrawCubeWires` | cubo / arestas do cubo |
| `DrawSphere(centro, raio, cor)` / `DrawSphereWires` | esfera |
| `DrawCylinder(pos, raio_topo, raio_base, altura, lados, cor)` | cilindro ou cone |
| `DrawPlane(centro, tamanho, cor)` | plano horizontal (XZ) |
| `DrawGrid(divisões, espaçamento)` | grade no chão, centrada na origem |
| `DrawLine3D(a, b, cor)` | linha no espaço |
| `DrawBillboard(cam, textura, pos, escala, tint)` | textura sempre virada para a câmera |

- São desenhadas na hora, sem carregar nada. Úteis para protótipos e depuração

> Tudo que é 3D precisa ser desenhado entre `BeginMode3D` e `EndMode3D`, com uma `Camera3D` definindo de onde se olha (ver `../camera/camera-3d.md`)
