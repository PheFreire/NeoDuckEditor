**pthread_join**

> `pthread.h`

O `pthread_join` bloqueia a thread chamadora até que a thread indicada termine sua execução

```c
#include <pthread.h>

int pthread_join(pthread_t thread, void **retval);
```

- `thread`: o identificador da thread a ser esperada
- `retval`: ponteiro para onde o valor de retorno da thread terminada será escrito; pode ser `NULL` se esse valor não for necessário

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha, por exemplo se a thread já tiver sido destacada (`pthread_detach`)
- Só funciona em threads "joinable" (o estado padrão ao criar uma thread); uma thread destacada não pode mais ser esperada com `pthread_join`
- Assim como um `fd` aberto precisa de um `close`, toda thread criada como joinable deveria ser esperada com `pthread_join` (ou destacada com `pthread_detach`), evitando deixar recursos presos até o processo terminar

```c
pthread_join(thread, NULL);
```

