**raymath**

> `raymath.h`

O `raymath.h` é a biblioteca de matemática do raylib: funções para vetores 2D, 3D e 4D, matrizes 4x4 e quaternions, além de utilitários como `Clamp` e `Lerp`. É um header separado do `raylib.h`, usado para movimento, física simples, câmeras, rotações e transformações de modelos

```c
#include "raylib.h"
#include "raymath.h"

Vector2 pos = { 100, 100 };
Vector2 alvo = GetMousePosition();

Vector2 direcao = Vector2Normalize(Vector2Subtract(alvo, pos));   // vetor de tamanho 1 apontando para o alvo
pos = Vector2Add(pos, Vector2Scale(direcao, 200 * GetFrameTime()));
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| vetores 2D | `vector2.md` |
| vetores 3D | `vector3.md` |
| vetores 4D | `vector4.md` |
| matrizes 4x4 | `matrix.md` |
| quaternions (rotações 3D) | `quaternion.md` |
| combinar escala, rotação e translação | `transformations.md` |
| interpolação: `Lerp`, `Clamp`, `Normalize`, `Remap` | `interpolation.md` |

- Cada função tem sua nota em `functions/`

---

**Convenções**

- As funções recebem e devolvem as structs **por valor**: `Vector2Add(a, b)` devolve um vetor novo e não altera `a` nem `b`
- Os nomes seguem o padrão `Tipo` + `Operação`: `Vector2Add`, `Vector3Normalize`, `MatrixRotateY`, `QuaternionSlerp`
- Ângulos são sempre em **radianos**. Use `DEG2RAD` e `RAD2DEG` para converter (`90 * DEG2RAD`)
- Vetores e matrizes usam `float`

```c
float angulo = 45 * DEG2RAD;                       // raymath
Vector2 v = Vector2Rotate((Vector2){ 1, 0 }, angulo);
DrawTextureEx(t, pos, 45, 1.0f, WHITE);            // funções de desenho do raylib usam graus
```

- Atenção à mistura: as funções de **desenho** do raylib (`DrawTextureEx`, `DrawRectanglePro`, `Camera2D.rotation`) usam **graus**, e o raymath usa **radianos**

---

**Header-only**

- As funções são definidas no próprio `raymath.h` como `inline`. Basta incluir o header
- Na compilação sem otimização (`-O0`), o compilador pode não expandir as funções `inline` e precisar das versões externas, que vêm compiladas dentro da `libraylib`. Por isso, ao usar o `raymath.h` sem linkar o raylib, defina `RAYMATH_STATIC_INLINE` antes do include
- O `raylib.h` não inclui o `raymath.h`: o include precisa ser feito explicitamente

> As funções são escritas para clareza, e não para máximo desempenho (sem SIMD). Para a maioria dos jogos, isso não é um gargalo, e o código fica fácil de ler e depurar
