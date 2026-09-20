**pthread_mutex_init**

> `pthread.h`

O `pthread_mutex_init` inicializa um mutex, deixando-o pronto para ser usado com `pthread_mutex_lock`/`pthread_mutex_unlock`

```c
#include <pthread.h>

int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutexattr_t *attr);
```

- `mutex`: ponteiro para a variável do mutex a ser inicializada
- `attr`: ponteiro para uma estrutura de atributos que controla o comportamento do mutex, como seu tipo; `NULL` para usar os atributos padrão

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Para mutexes alocados estaticamente ou globais, existe a alternativa `pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;`, que dispensa a chamada explícita a `pthread_mutex_init` com atributos padrão
- Todo mutex inicializado com sucesso deve ser pareado com um `pthread_mutex_destroy` quando não for mais necessário

```c
pthread_mutex_t mutex;
pthread_mutex_init(&mutex, NULL);
```

