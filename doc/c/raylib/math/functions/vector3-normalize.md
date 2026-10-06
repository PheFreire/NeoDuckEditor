**Vector3Normalize**

> `raymath.h`

O `Vector3Normalize` devolve um vetor 3D com a mesma direção e tamanho `1`

```c
Vector3 Vector3Normalize(Vector3 v);
```

- `v`: o vetor

- Devolve `v / Vector3Length(v)`
- Para o vetor nulo `(0, 0, 0)`, devolve `(0, 0, 0)`

```c
// projétil disparado da câmera na direção do olhar
Vector3 dir = Vector3Normalize(Vector3Subtract(cam.target, cam.position));
bala.pos = cam.position;
bala.vel = Vector3Scale(dir, 30.0f);
```

> Vetores usados como direção (normais, direção da luz, direção do olhar) devem estar normalizados: produto escalar, reflexão e iluminação assumem tamanho `1` e dão resultados errados com outros tamanhos (ver `vector3-dot-product.md`)
