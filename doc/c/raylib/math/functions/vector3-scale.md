**Vector3Scale**

> `raymath.h`

O `Vector3Scale` multiplica as três coordenadas de um vetor 3D por um número

```c
Vector3 Vector3Scale(Vector3 v, float scalar);
```

- `v`: o vetor
- `scalar`: o fator

- Devolve `(v.x * scalar, v.y * scalar, v.z * scalar)`

```c
// andar na direção da câmera
Vector3 frente = Vector3Normalize(Vector3Subtract(cam.target, cam.position));
Vector3 passo = Vector3Scale(frente, 5.0f * GetFrameTime());   // 5 unidades por segundo
cam.position = Vector3Add(cam.position, passo);
cam.target   = Vector3Add(cam.target, passo);
```

> Para escalar cada eixo por um valor diferente, use `Vector3Multiply(v, (Vector3){ sx, sy, sz })`
