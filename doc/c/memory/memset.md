**memset**

> `string.h`

O `memset` preenche um bloco de memória com um valor de byte específico, copiando um valor convertido para `unsigned char` para uma quantidade de bytes. Muito usado para limpar buffers ou zerar arrays

```c
#include <string.h>

void *memset(void *ptr, int value, size_t num);
```

- `ptr`: o ponteiro para o início do bloco de memória a ser preenchido
- `value`: o valor a ser escrito em cada byte; embora o parâmetro seja um `int`, apenas o byte menos significativo é usado, já que o valor é convertido para `unsigned char` antes de ser escrito
- `num`: a quantidade de bytes a serem preenchidos a partir de `ptr`

- Retorna o próprio ponteiro `ptr`
- Preenche byte a byte, então só serve para valores que cabem em 1 byte (`0` a `255`); não é possível usar `memset` para inicializar um array de `int` com um valor diferente de `0`, pois cada `int` acabaria com o mesmo byte repetido em suas 4 posições, e não com o número esperado
- `num` deve respeitar o tamanho real do bloco apontado por `ptr`; preencher além dele é um *buffer overflow*

> Diferente do `memmove`, o `memset` não precisa de um segundo ponteiro, pois o mesmo valor é repetido em todos os bytes

```c
char buffer[10];
memset(buffer, 0, sizeof(buffer)); // zera os 10 bytes do buffer

int arr[5];
memset(arr, 1, sizeof(arr)); // NÃO vira {1,1,1,1,1}; cada int fica 0x01010101 (16843009)
```

