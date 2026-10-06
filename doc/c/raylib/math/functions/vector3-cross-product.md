**Vector3CrossProduct**

> `raymath.h`

O `Vector3CrossProduct` calcula o produto vetorial de dois vetores 3D: um terceiro vetor **perpendicular** aos dois, cujo sentido segue a regra da mão direita

```c
Vector3 Vector3CrossProduct(Vector3 v1, Vector3 v2);
```

- `v1`, `v2`: os vetores

- Devolve `(v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x)`
- O tamanho do resultado é a área do paralelogramo formado pelos dois vetores. Vetores paralelos dão `(0, 0, 0)`
- Inverter a ordem inverte o sentido do resultado

```c
// vetor "direita" de uma câmera, para andar de lado (strafe)
Vector3 frente  = Vector3Normalize(Vector3Subtract(cam.target, cam.position));
Vector3 direita = Vector3Normalize(Vector3CrossProduct(frente, cam.up));

// normal de um triângulo
Vector3 normal = Vector3Normalize(Vector3CrossProduct(Vector3Subtract(b, a), Vector3Subtract(c, a)));
```

```text
frente (0, 0, -1) × cima (0, 1, 0) = direita (1, 0, 0)
```

> Com vértices em sentido anti-horário, a normal calculada assim aponta para fora da face, que é o lado considerado "da frente" pela GPU (ver `../vector3.md`)
