**free**

> `stdlib.h`

O `free` é a função mais crítica associada a gerenciamento de memória. Ela avisa ao sistema que aquele bloco de memória não está mais em uso, devolvendo ele para ser reaproveitado

```c
void free(void *ponteiro);
```

- Não apaga o endereço guardado no ponteiro, apenas libera o bloco de memória, deixando o ponteiro dangling
- Se o `free` não é usado, o bloco fica preso, ocupando espaço até o fim do programa (memory leak)

```c
int *p = malloc(sizeof(int));
free(p);
```

> Toda alocação feita com `malloc`, `calloc` ou `realloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa
