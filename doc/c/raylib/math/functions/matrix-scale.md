**MatrixScale**

> `raymath.h`

O `MatrixScale` cria uma matriz que multiplica as coordenadas dos pontos por um fator em cada eixo, aumentando, diminuindo ou espelhando o objeto

```c
Matrix MatrixScale(float x, float y, float z);
```

- `x`, `y`, `z`: o fator de cada eixo (`1` = sem mudança)

- Devolve a matriz de escala
- Fator negativo espelha naquele eixo

```c
Matrix m = MatrixMultiply(MatrixScale(1, 2, 1), MatrixTranslate(0, 1, 0));   // cubo esticado na altura
DrawMesh(cubo, material, m);
```

> Escala não uniforme (eixos com fatores diferentes) deforma as normais da mesh, e a iluminação pode ficar errada. Os shaders corrigem isso com a matriz normal (`matNormal`), que o raylib calcula e envia automaticamente
