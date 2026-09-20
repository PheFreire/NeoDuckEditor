**realloc**

> `stdlib.h`

O `realloc` (Re-allocation) muda o tamanho de um bloco que já foi alocado por `malloc`, `calloc` ou pelo próprio `realloc`

```c
#include <stdlib.h>

void *realloc(void *ponteiro, size_t novo_tamanho);
```

- `ponteiro`: o bloco previamente alocado a ser redimensionado; se for `NULL`, o `realloc` se comporta como um `malloc(novo_tamanho)` comum
- `novo_tamanho`: o novo tamanho desejado, em bytes, para o bloco; se for `0` e `ponteiro` não for `NULL`, o comportamento é equivalente a um `free(ponteiro)` (dependendo da implementação, podendo também retornar um ponteiro válido para um bloco de tamanho zero)

- Se o bloco atual tiver espaço livre ao lado, ele apenas estica o bloco no mesmo endereço
- Se não couber, ele aloca um novo bloco em outro endereço, copia o conteúdo antigo para lá (até o menor entre o tamanho antigo e o novo) e libera o bloco antigo, devolvendo o novo ponteiro
- Por isso sempre se deve guardar o retorno do `realloc`, pois o ponteiro antigo pode não ser mais válido
- Retorna `NULL` se a alocação falhar; nesse caso, o bloco original apontado por `ponteiro` continua válido e intacto, então atribuir o retorno diretamente à mesma variável (`p = realloc(p, tamanho);`) sem checar `NULL` faz o programa perder a referência ao bloco original, causando um *memory leak* caso a alocação falhe

```c
int *p = malloc(3 * sizeof(int));
p = realloc(p, 5 * sizeof(int)); // agora p tem espaço para 5 inteiros
```

> Toda alocação feita com `realloc` deve, obrigatoriamente, ser liberada com `free`. Caso contrário a memória fica presa até o fim do programa

