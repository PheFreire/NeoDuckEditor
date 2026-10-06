**MatrixRotate**

> `raymath.h`

O `MatrixRotate` cria uma matriz que gira pontos em torno de um eixo qualquer que passa pela origem

```c
Matrix MatrixRotate(Vector3 axis, float angle);
```

- `axis`: o eixo de rotação (é normalizado internamente)
- `angle`: o ângulo, em **radianos**

- Devolve a matriz de rotação

```c
// girar em torno de um eixo inclinado
Matrix m = MatrixRotate((Vector3){ 1, 1, 0 }, GetTime());
modelo.transform = m;

// em torno dos eixos principais, as versões específicas são mais diretas
Matrix y = MatrixRotateY(45 * DEG2RAD);
Matrix xyz = MatrixRotateXYZ((Vector3){ pitch, yaw, roll });   // radianos
```

> O ângulo é em radianos, ao contrário do `DrawModelEx`, que recebe graus. Esquecer o `DEG2RAD` faz um "giro de 90" virar quase 15 voltas (90 radianos), e o objeto parece apontar para uma direção aleatória
