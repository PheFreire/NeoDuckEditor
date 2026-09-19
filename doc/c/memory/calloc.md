**calloc**

> `stdlib.h`

O `calloc` (Contiguous Allocation) assim como o `malloc` também aloca um bloco no Heap, mas com dois diferenciais

```c
void *calloc(size_t quantidade, size_t tamanho);
```

- Zera todo o bloco alocado, colocando todos os bits como 0
- Recebe a quantidade de itens e o tamanho de cada item separadamente, em vez de um único valor total

```c
int *p = calloc(3, sizeof(int)); // reserva espaço para 3 inteiros, todos zerados
```

> Toda alocação feita com `calloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa
