**realloc**

> `stdlib.h`

O `realloc` (Re-allocation) muda o tamanho de um bloco que já foi alocado por `malloc`, `calloc` ou pelo próprio `realloc`

```c
void *realloc(void *ponteiro, size_t novo_tamanho);
```

- Se o bloco atual tiver espaço livre ao lado, ele apenas estica o bloco no mesmo endereço
- Se não couber, ele aloca um novo bloco em outro endereço, copia o conteúdo antigo para lá e libera o bloco antigo, devolvendo o novo ponteiro
- Por isso sempre se deve guardar o retorno do `realloc`, pois o ponteiro antigo pode não ser mais válido

```c
int *p = malloc(3 * sizeof(int));
p = realloc(p, 5 * sizeof(int)); // agora p tem espaço para 5 inteiros
```

> Toda alocação feita com `realloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa
