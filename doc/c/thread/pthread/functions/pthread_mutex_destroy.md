**pthread_mutex_destroy**

> `pthread.h`

O `pthread_mutex_destroy` libera os recursos internos associados a um mutex que não será mais usado

```c
#include <pthread.h>

int pthread_mutex_destroy(pthread_mutex_t *mutex);
```

- `mutex`: ponteiro para o mutex a ser destruído

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Não deve ser chamado sobre um mutex que ainda está travado ou que alguma thread ainda está tentando travar
- Depois de destruído, o mutex só pode voltar a ser usado se for reinicializado com `pthread_mutex_init`

```c
pthread_mutex_destroy(&mutex);
```

