**Camera3D**

> `raylib.h` — módulos `rcore` e `rcamera`

A `Camera3D` define de onde e para onde se olha em uma cena 3D, e como a cena é projetada na tela (com ou sem perspectiva). `Camera` é um apelido para `Camera3D`

```c
typedef struct Camera3D {
  Vector3 position;    // onde a câmera está
  Vector3 target;      // o ponto para onde ela olha
  Vector3 up;          // qual direção é "para cima" (normalmente (0, 1, 0))
  float fovy;          // campo de visão vertical, em graus (perspectiva)
  int projection;      // CAMERA_PERSPECTIVE ou CAMERA_ORTHOGRAPHIC
} Camera3D;

typedef Camera3D Camera;
```

```c
Camera3D cam = {
  .position   = { 10, 10, 10 },   // acima e afastada
  .target     = { 0, 0, 0 },      // olhando para a origem
  .up         = { 0, 1, 0 },      // y para cima
  .fovy       = 45,
  .projection = CAMERA_PERSPECTIVE,
};

BeginDrawing();
ClearBackground(RAYWHITE);
BeginMode3D(cam);
  DrawCube((Vector3){ 0, 1, 0 }, 2, 2, 2, RED);
  DrawGrid(10, 1);   // chão de referência
EndMode3D();
EndDrawing();
```

---

**Os vetores da câmera**

```text
                 up (0, 1, 0)
                  ▲
                  │
   position ●─────┼─────────► target
   (câmera)       │   direção do olhar = target - position
```

- `position` e `target` definem a direção do olhar
- `up` define a rotação em torno dessa direção: com `(0, 1, 0)`, o eixo `y` aparece para cima na tela
- No raylib, o 3D é **destro (right-handed)** com `y` para cima: `x` para a direita, `y` para cima e `z` saindo da tela em direção ao observador

---

**Projeção**

| Projeção | Efeito | `fovy` significa |
|----------|--------|------------------|
| `CAMERA_PERSPECTIVE` | objetos longe parecem menores, como no olho humano | ângulo de abertura vertical (graus) |
| `CAMERA_ORTHOGRAPHIC` | sem perspectiva: o tamanho não muda com a distância | largura visível da cena, em unidades |

- Perspectiva com `fovy` entre `45` e `75` é o padrão de jogos em primeira e terceira pessoa
- Ortográfica é usada em jogos isométricos, editores e jogos de estratégia

---

**Modos prontos**

O `UpdateCamera` move a câmera de acordo com o input, em modos prontos:

| Modo | Comportamento |
|------|---------------|
| `CAMERA_CUSTOM` | não faz nada: o programa controla a câmera |
| `CAMERA_FREE` | voo livre com teclado e mouse |
| `CAMERA_ORBITAL` | gira ao redor do `target` automaticamente, com zoom pela roda |
| `CAMERA_FIRST_PERSON` | primeira pessoa: WASD + mouse |
| `CAMERA_THIRD_PERSON` | terceira pessoa ao redor do `target` |

> O `UpdateCamera` é ótimo para protótipos e visualizadores. Em um jogo, a câmera normalmente é calculada pelo próprio programa a partir da posição do personagem, com `CAMERA_CUSTOM` ou sem chamar o `UpdateCamera` (ver `functions/update-camera.md`)
