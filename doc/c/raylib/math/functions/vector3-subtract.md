**Vector3Subtract**

> `raymath.h`

O `Vector3Subtract` subtrai um vetor 3D de outro. `Vector3Subtract(b, a)` é o vetor que vai do ponto `a` até o ponto `b`

```c
Vector3 Vector3Subtract(Vector3 v1, Vector3 v2);
```

- `v1`, `v2`: os vetores

- Devolve `(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)`

```c
// direção para onde a câmera olha
Vector3 frente = Vector3Normalize(Vector3Subtract(camera.target, camera.position));

// distância do jogador até um item
float d = Vector3Length(Vector3Subtract(item.pos, jogador.pos));
```

> A regra é "destino menos origem". Inverter a ordem inverte a direção do vetor resultante
