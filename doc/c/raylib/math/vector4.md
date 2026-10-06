**Vector4**

> `raymath.h` — tipo `Vector4`

Um `Vector4` é um conjunto de quatro `float` (`x`, `y`, `z`, `w`). No raylib, ele é usado principalmente para três coisas: cores em ponto flutuante (para shaders), coordenadas homogêneas em contas com matrizes 4x4, e quaternions (que são um `Vector4` com outro nome)

```c
typedef struct Vector4 {
  float x;
  float y;
  float z;
  float w;
} Vector4;

typedef Vector4 Quaternion;
```

---

**Cor como Vector4**

```c
Vector4 cor = ColorNormalize(ORANGE);   // (1.0, 0.63, 0.0, 1.0): canais de 0 a 1
SetShaderValue(shader, loc_cor, &cor, SHADER_UNIFORM_VEC4);

Color de_volta = ColorFromNormalized(cor);   // volta para 0 a 255
```

- Shaders trabalham com cores de `0.0` a `1.0`. O `ColorNormalize` converte uma `Color` (`0` a `255`) para esse formato

---

**Coordenadas homogêneas**

```text
ponto no espaço:    (x, y, z, 1)    w = 1: é afetado pela translação da matriz
direção:            (x, y, z, 0)    w = 0: só é girado e escalado, não transladado
```

- É por isso que as matrizes de transformação são 4x4 para um espaço 3D: a quarta coordenada permite representar a translação como uma multiplicação (ver `matrix.md`)

---

**Funções**

- `Vector4Add`, `Vector4Subtract`, `Vector4Scale`, `Vector4Length`, `Vector4Normalize`, `Vector4Lerp`, `Vector4DotProduct`, `Vector4Distance`, `Vector4Equals`, com o mesmo comportamento das versões 2D e 3D

> Quaternions são `Vector4`, mas não devem ser manipulados com as funções de vetor (somar dois quaternions não combina duas rotações). Para rotações, use as funções `Quaternion...` (ver `quaternion.md`)
