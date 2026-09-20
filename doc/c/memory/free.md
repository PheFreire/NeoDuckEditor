**free**

> `stdlib.h`

O `free` é a função mais crítica associada a gerenciamento de memória. Ela avisa ao sistema que aquele bloco de memória não está mais em uso, devolvendo ele para ser reaproveitado

```c
#include <stdlib.h>

void free(void *ponteiro);
```

- `ponteiro`: o endereço do bloco a ser liberado, previamente retornado por `malloc`, `calloc` ou `realloc`

- Não apaga o endereço guardado no ponteiro, apenas libera o bloco de memória, deixando o ponteiro dangling (apontando para um endereço que não pertence mais ao programa); usar esse ponteiro depois do `free` sem reatribuí-lo é comportamento indefinido
- Se o `free` não é usado, o bloco fica preso, ocupando espaço até o fim do programa (memory leak)
- Chamar `free` duas vezes sobre o mesmo ponteiro (*double free*) também é comportamento indefinido, podendo corromper as estruturas internas do alocador; passar `NULL` para `free`, por outro lado, é seguro e não faz nada
- Passar para `free` um ponteiro que não veio de `malloc`/`calloc`/`realloc` (por exemplo, um endereço de uma variável na stack) é comportamento indefinido

```c
int *p = malloc(sizeof(int));
free(p);
```

> Toda alocação feita com `malloc`, `calloc` ou `realloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa

