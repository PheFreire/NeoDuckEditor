**QuaternionIdentity**

> `raymath.h`

O `QuaternionIdentity` devolve o quaternion que representa "nenhuma rotação". É o valor inicial de uma orientação

```c
Quaternion QuaternionIdentity(void);
```

- Devolve `(0, 0, 0, 1)`: `x`, `y`, `z` zerados e `w = 1`

```c
typedef struct {
  Vector3 pos;
  Quaternion rot;
} Objeto;

Objeto nave = { .pos = { 0, 0, 0 }, .rot = QuaternionIdentity() };

// acumular uma rotação de 90 graus por segundo em y
Quaternion giro = QuaternionFromAxisAngle((Vector3){ 0, 1, 0 }, 90 * DEG2RAD * GetFrameTime());
nave.rot = QuaternionNormalize(QuaternionMultiply(nave.rot, giro));
```

> Um quaternion zerado `(0, 0, 0, 0)` não é uma rotação válida: inicializar uma struct com `{ 0 }` deixa a orientação inválida. Use sempre o `QuaternionIdentity` como valor inicial (ver `../quaternion.md`)
