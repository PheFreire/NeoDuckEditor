**Colisão 3D**

> `raylib.h` — módulo `rmodels`

A colisão 3D usa as mesmas ideias da 2D com uma dimensão a mais: esferas no lugar de círculos, caixas (bounding boxes) no lugar de retângulos e raios no lugar de segmentos. Os raios são especialmente importantes em 3D, pois são a forma de saber em qual objeto o mouse clicou

```c
typedef struct BoundingBox {
  Vector3 min;   // canto com os menores x, y, z
  Vector3 max;   // canto com os maiores x, y, z
} BoundingBox;

typedef struct Ray {
  Vector3 position;    // origem
  Vector3 direction;   // direção (normalizada)
} Ray;

typedef struct RayCollision {
  bool hit;          // acertou algo?
  float distance;    // distância da origem até o ponto
  Vector3 point;     // onde acertou
  Vector3 normal;    // normal da superfície no ponto
} RayCollision;
```

---

**Funções**

| Função | Testa |
|--------|-------|
| `CheckCollisionSpheres(c1, r1, c2, r2)` | esfera com esfera |
| `CheckCollisionBoxes(a, b)` | caixa com caixa |
| `CheckCollisionBoxSphere(box, c, r)` | caixa com esfera |
| `GetRayCollisionBox(ray, box)` | raio com caixa |
| `GetRayCollisionSphere(ray, c, r)` | raio com esfera |
| `GetRayCollisionTriangle(ray, a, b, c)` | raio com triângulo |
| `GetRayCollisionMesh(ray, mesh, transform)` | raio com todos os triângulos de uma mesh |

---

**Bounding box**

```text
            max (x2, y2, z2)
       ┌──────────●
      ╱│         ╱│
     ┌──────────┐ │
     │ │        │ │
     │ └────────│─┘
     │╱         │╱
     ●──────────┘
min (x1, y1, z1)
```

- Uma `BoundingBox` alinhada aos eixos (AABB) é descrita só por dois cantos opostos
- `GetModelBoundingBox(model)` e `GetMeshBoundingBox(mesh)` calculam a caixa de um modelo carregado. A caixa é no espaço local do modelo: para usá-la na posição do objeto, some a posição a `min` e `max`
- `DrawBoundingBox(box, cor)` desenha a caixa em arame, útil para depurar

---

**Clicando em objetos 3D**

```c
Ray raio = GetScreenToWorldRay(GetMousePosition(), camera);   // do mouse para dentro da cena

RayCollision hit = GetRayCollisionBox(raio, caixa_do_cubo);
if (hit.hit && IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
  selecionado = true;
  TraceLog(LOG_INFO, "clique a %.2f unidades, em (%.1f, %.1f, %.1f)",
           hit.distance, hit.point.x, hit.point.y, hit.point.z);
}
```

- Com vários objetos, o mais próximo da câmera é o de menor `distance` entre os que têm `hit` verdadeiro

> Testes de raio com mesh (`GetRayCollisionMesh`) verificam cada triângulo e são caros para modelos detalhados. O padrão é testar primeiro a bounding box (barato) e só testar a mesh quando o raio acerta a caixa
