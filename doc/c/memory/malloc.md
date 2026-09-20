**malloc**

> `stdlib.h`

O `malloc` (Memory Allocation) é a função mais básica de alocação. Você pede uma quantidade de bytes e ela devolve um ponteiro para o início de um bloco livre com esse tamanho

```c
#include <stdlib.h>

void *malloc(size_t tamanho);
```

- `tamanho`: a quantidade de bytes a serem alocados

- Não inicializa o conteúdo do bloco, então os valores dentro dele começam como lixo (o conteúdo que já estava naquele espaço de memória antes)
- Devolve um ponteiro para o início do bloco alocado, ou `NULL` quando não há memória disponível para atender o pedido
- O ponteiro retornado é `void *`, podendo ser atribuído diretamente a um ponteiro de qualquer tipo sem a necessidade de *cast* em C (diferente do C++, onde o *cast* é obrigatório)

```c
int *p = malloc(3 * sizeof(int)); // reserva espaço para 3 inteiros, com lixo dentro
```

> Toda alocação feita com `malloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa

