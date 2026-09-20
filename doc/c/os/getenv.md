**getenv**

> `stdlib.h`

O `getenv` busca o valor de uma variável de ambiente do processo atual, retornando o texto associado ao nome informado

```c
#include <stdlib.h>

char *getenv(const char *name);
```

- `name`: o nome da variável de ambiente a ser consultada

- Retorna um ponteiro para o valor da variável, ou `NULL` caso ela não exista
- O ponteiro retornado aponta para uma área interna do ambiente do processo; não deve ser modificado ou liberado (`free`) diretamente

```c
char *home = getenv("HOME");
if (home != NULL) {
    printf("HOME=%s\n", home);
}
```

