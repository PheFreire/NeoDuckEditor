**MatrixIdentity**

> `raymath.h`

O `MatrixIdentity` devolve a matriz identidade: a transformação que não muda nada. É o ponto de partida para acumular transformações e o valor "neutro" de uma matriz

```c
Matrix MatrixIdentity(void);
```

- Devolve a matriz com `1` na diagonal e `0` no resto

```text
| 1 0 0 0 |
| 0 1 0 0 |      ponto × identidade = o mesmo ponto
| 0 0 1 0 |
| 0 0 0 1 |
```

```c
Matrix t = MatrixIdentity();
if (girar)   t = MatrixMultiply(t, MatrixRotateY(ang));
if (mover)   t = MatrixMultiply(t, MatrixTranslate(x, 0, z));
modelo.transform = t;   // sem nenhuma opção, o modelo fica como estava
```

> A `model.transform` de um modelo recém-carregado é a identidade. Atribuir `MatrixIdentity()` a ela desfaz qualquer transformação aplicada antes
