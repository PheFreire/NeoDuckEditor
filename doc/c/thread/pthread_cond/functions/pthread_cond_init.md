**pthread_cond_init**

> `pthread.h`

O `pthread_cond_init` inicializa uma variável de condição, deixando-a pronta para ser usada com `pthread_cond_wait`, `pthread_cond_signal` e `pthread_cond_broadcast`

```c
#include <pthread.h>

int pthread_cond_init(pthread_cond_t *cond, const pthread_condattr_t *attr);
```

- `cond`: ponteiro para a variável de condição a ser inicializada
- `attr`: ponteiro para uma estrutura de atributos que controla seu comportamento, por exemplo qual relógio usar em `pthread_cond_timedwait`; `NULL` para usar os atributos padrão

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Assim como o mutex, tem uma versão estática de inicialização, `pthread_cond_t cond = PTHREAD_COND_INITIALIZER;`, equivalente a chamar `pthread_cond_init` com atributos padrão
- Toda variável de condição inicializada com sucesso deve ser pareada com um `pthread_cond_destroy` quando não for mais necessária

```c
pthread_cond_t cond;
pthread_cond_init(&cond, NULL);
```

