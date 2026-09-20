**pthread_cond_destroy**

> `pthread.h`

O `pthread_cond_destroy` libera os recursos internos associados a uma variável de condição que não será mais usada

```c
#include <pthread.h>

int pthread_cond_destroy(pthread_cond_t *cond);
```

- `cond`: ponteiro para a variável de condição a ser destruída

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Não deve ser chamado enquanto alguma thread ainda está esperando nela (dentro de `pthread_cond_wait`)
- Depois de destruída, a variável só pode voltar a ser usada se for reinicializada com `pthread_cond_init`

```c
pthread_cond_destroy(&cond);
```

