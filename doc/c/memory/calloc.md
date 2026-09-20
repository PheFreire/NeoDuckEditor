**calloc**

> `stdlib.h`

O `calloc` (Contiguous Allocation) assim como o `malloc` também aloca um bloco no Heap, mas com dois diferenciais

```c
#include <stdlib.h>

void *calloc(size_t quantidade, size_t tamanho);
```

- `quantidade`: o número de itens a serem alocados
- `tamanho`: o tamanho, em bytes, de cada item

- Zera todo o bloco alocado, colocando todos os bits como `0`, diferente do `malloc`, que retorna memória com lixo (o conteúdo anterior daquele espaço)
- Recebe a quantidade de itens e o tamanho de cada item separadamente, em vez de um único valor total como o `malloc`; isso permite à própria função checar overflow na multiplicação `quantidade * tamanho`, retornando `NULL` se o resultado não couber em `size_t`, algo que `malloc(quantidade * tamanho)` não faz sozinho
- Retorna um ponteiro para o início do bloco alocado, ou `NULL` em caso de falha na alocação (incluindo o overflow citado acima)
- Equivale, na prática, a chamar `malloc` seguido de `memset(ptr, 0, tamanho_total)`, mas como uma única chamada, podendo ser feita de forma mais eficiente internamente

```c
int *p = calloc(3, sizeof(int)); // reserva espaço para 3 inteiros, todos zerados
```

> Toda alocação feita com `calloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa

