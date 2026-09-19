**malloc**

> `stdlib.h`

O `malloc` (Memory Allocation) é a função mais básica de alocação. Você pede uma quantidade de bytes e ela devolve um ponteiro para o início de um bloco livre com esse tamanho

```c
void *malloc(size_t tamanho);
```

- Não inicializa o conteúdo do bloco, então os valores dentro dele começam como lixo
- Devolve `NULL` quando não há memória disponível para atender o pedido

```c
int *p = malloc(3 * sizeof(int)); // reserva espaço para 3 inteiros, com lixo dentro
```

> Toda alocação feita com `malloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa
