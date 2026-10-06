**Vector3DotProduct**

> `raymath.h`

O `Vector3DotProduct` calcula o produto escalar de dois vetores 3D. Com vetores normalizados, o resultado é o cosseno do ângulo entre eles: mede o quanto as duas direções estão alinhadas

```c
float Vector3DotProduct(Vector3 v1, Vector3 v2);
```

- `v1`, `v2`: os vetores

- Devolve `v1.x * v2.x + v1.y * v2.y + v1.z * v2.z`

```text
com v1 e v2 normalizados:
   1   mesma direção
   0   perpendiculares
  -1   direções opostas
```

```c
// o inimigo está no campo de visão do jogador? (cone de 60 graus)
Vector3 olhar = Vector3Normalize(Vector3Subtract(cam.target, cam.position));
Vector3 para_inimigo = Vector3Normalize(Vector3Subtract(inimigo.pos, cam.position));
bool visivel = Vector3DotProduct(olhar, para_inimigo) > cosf(30 * DEG2RAD);   // metade do cone

// iluminação difusa: brilho conforme a superfície encara a luz
float brilho = fmaxf(0.0f, Vector3DotProduct(normal, Vector3Negate(direcao_luz)));
```

> Comparar o produto escalar com o cosseno de um ângulo evita calcular o ângulo em si (que precisaria de `acosf`). É o mesmo princípio usado nos shaders de iluminação
