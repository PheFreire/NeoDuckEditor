**Quaternion**

> `raymath.h` — tipo `Quaternion`

Um quaternion é uma forma de representar uma **rotação 3D** com quatro números. Comparado a ângulos de Euler (rotação em `x`, `y` e `z` separadamente), ele não sofre de gimbal lock e permite interpolar suavemente entre duas orientações. É usado em animações de esqueleto, câmeras e objetos que giram livremente

```c
typedef Vector4 Quaternion;   // x, y, z, w
```

- Para rotações, os quaternions usados têm tamanho 1 (são **unitários**). `QuaternionNormalize` garante isso

---

**Criando e convertendo**

| Função | Faz |
|--------|-----|
| `QuaternionIdentity()` | nenhuma rotação |
| `QuaternionFromAxisAngle(eixo, ang)` | girar `ang` radianos em torno de `eixo` |
| `QuaternionFromEuler(pitch, yaw, roll)` | a partir de ângulos de Euler |
| `QuaternionToEuler(q)` | de volta para ângulos de Euler |
| `QuaternionFromMatrix(m)` / `QuaternionToMatrix(q)` | converter de/para matriz |
| `QuaternionFromVector3ToVector3(de, para)` | rotação que leva uma direção até outra |

---

**Combinando e interpolando**

| Função | Faz |
|--------|-----|
| `QuaternionMultiply(a, b)` | combina duas rotações |
| `QuaternionInvert(q)` | rotação inversa |
| `QuaternionNormalize(q)` | corrige o tamanho para 1 |
| `QuaternionSlerp(a, b, t)` | interpolação esférica: gira suavemente de `a` para `b` |
| `Vector3RotateByQuaternion(v, q)` | aplica a rotação a um vetor |

```c
// virar suavemente para uma nova direção
Quaternion atual = nave.rotacao;
Quaternion alvo  = QuaternionFromAxisAngle((Vector3){ 0, 1, 0 }, angulo_alvo);
nave.rotacao = QuaternionSlerp(atual, alvo, 5.0f * GetFrameTime());

// usar no desenho
modelo.transform = QuaternionToMatrix(nave.rotacao);
DrawModel(modelo, nave.pos, 1.0f, WHITE);
```

---

**Gimbal lock**

```text
Euler: girar em x, depois y, depois z
quando a rotação do meio chega a 90 graus, dois eixos passam a girar no mesmo plano
→ perde-se um grau de liberdade, e interpolar entre ângulos produz caminhos estranhos
```

- Quaternions representam a orientação inteira de uma vez, sem esse problema
- Para objetos que só giram em um eixo (um personagem virando no chão), um único ângulo é mais simples e suficiente

> Multiplicar muitos quaternions em sequência acumula pequenos erros de ponto flutuante, e o tamanho deixa de ser exatamente 1, distorcendo a rotação. Normalize de vez em quando com `QuaternionNormalize` (ver `functions/quaternion-normalize.md`)
