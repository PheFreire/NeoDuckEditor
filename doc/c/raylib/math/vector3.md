**Vector3**

> `raymath.h` — tipo `Vector3`

Um `Vector3` é um trio de `float` (`x`, `y`, `z`) usado em 3D para posições, direções, velocidades, normais de superfície e escalas. No raylib, o eixo `y` aponta para cima

```c
typedef struct Vector3 {
  float x;
  float y;
  float z;
} Vector3;
```

```text
        y (cima)
        │
        │
        └──────── x (direita)
       ╱
      z (em direção ao observador)
```

- O sistema é **destro** (right-handed): com `x` para a direita e `y` para cima, `z` sai da tela em direção a quem olha

---

**Operações**

| Função | Resultado |
|--------|-----------|
| `Vector3Add(a, b)` / `Vector3Subtract(a, b)` | soma / diferença |
| `Vector3Scale(v, s)` | multiplicar por um número |
| `Vector3Length(v)` | tamanho |
| `Vector3Normalize(v)` | direção com tamanho 1 |
| `Vector3Distance(a, b)` | distância entre pontos |
| `Vector3DotProduct(a, b)` | alinhamento entre direções |
| `Vector3CrossProduct(a, b)` | vetor perpendicular aos dois |
| `Vector3Lerp(a, b, t)` | interpolação |
| `Vector3RotateByAxisAngle(v, eixo, ang)` | girar em torno de um eixo |
| `Vector3Transform(v, matriz)` | aplicar uma matriz de transformação |

---

**Produto vetorial**

```text
a × b é perpendicular a a e a b, seguindo a regra da mão direita

  frente (0, 0, -1) × cima (0, 1, 0) = direita (1, 0, 0)
```

```c
// vetores da câmera a partir da direção do olhar
Vector3 frente  = Vector3Normalize(Vector3Subtract(cam.target, cam.position));
Vector3 direita = Vector3Normalize(Vector3CrossProduct(frente, cam.up));

if (IsKeyDown(KEY_D)) cam.position = Vector3Add(cam.position, Vector3Scale(direita, vel * dt));
```

- A ordem importa: `Vector3CrossProduct(b, a)` dá o vetor oposto

---

**Normais e iluminação**

- A normal de um triângulo é o produto vetorial de duas arestas: `Vector3Normalize(Vector3CrossProduct(Vector3Subtract(b, a), Vector3Subtract(c, a)))`
- O brilho de uma superfície iluminada é proporcional a `Vector3DotProduct(normal, direcao_da_luz)`: `1` de frente para a luz, `0` de lado

> As mesmas ideias do `Vector2` valem aqui com uma coordenada a mais. A maioria das funções existe nas duas versões com o mesmo nome e o prefixo trocado (ver `vector2.md`)
