**QuaternionNormalize**

> `raymath.h`

O `QuaternionNormalize` ajusta um quaternion para ter tamanho `1`, que é a condição para ele representar uma rotação pura

```c
Quaternion QuaternionNormalize(Quaternion q);
```

- `q`: o quaternion

- Devolve `q` dividido pelo próprio tamanho
- Um quaternion de tamanho zero é tratado sem divisão por zero

```c
// rotação acumulada todo frame
nave.rot = QuaternionMultiply(nave.rot, giro_do_frame);
nave.rot = QuaternionNormalize(nave.rot);   // corrige o erro acumulado
modelo.transform = QuaternionToMatrix(nave.rot);
```

---

**Por que normalizar**

```text
cada multiplicação de floats tem um pequeno erro de arredondamento
depois de milhares de frames: tamanho 1,0003 → 1,02 → ...
quaternion fora do tamanho 1 → a matriz gerada também escala o objeto
```

> Normalizar a cada atualização é barato e evita que o objeto cresça, encolha ou se deforme lentamente com o passar do tempo (ver `../quaternion.md`)
