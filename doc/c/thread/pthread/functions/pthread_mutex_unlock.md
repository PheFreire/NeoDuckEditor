**pthread_mutex_unlock**

> `pthread.h`

O `pthread_mutex_unlock` libera (destrava) um mutex previamente travado pela mesma thread, permitindo que outra thread o adquira

```c
#include <pthread.h>

int pthread_mutex_unlock(pthread_mutex_t *mutex);
```

- `mutex`: ponteiro para o mutex a ser destravado

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Deve ser chamado pela mesma thread que executou o `pthread_mutex_lock` correspondente; destravar um mutex a partir de outra thread é comportamento indefinido
- Depois de destravado, não há garantia de qual thread em espera (se houver alguma) vai conseguir travá-lo em seguida

```c
contador++;
pthread_mutex_unlock(&mutex);
```

