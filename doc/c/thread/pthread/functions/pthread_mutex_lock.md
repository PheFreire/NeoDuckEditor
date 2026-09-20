**pthread_mutex_lock**

> `pthread.h`

O `pthread_mutex_lock` adquire (trava) um mutex, bloqueando a thread chamadora até que ele esteja disponível

```c
#include <pthread.h>

int pthread_mutex_lock(pthread_mutex_t *mutex);
```

- `mutex`: ponteiro para o mutex a ser travado

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Se o mutex já estiver travado por outra thread, a chamada bloqueia até que ele seja liberado com `pthread_mutex_unlock`
- Só uma thread pode manter um mutex travado por vez; envolver a leitura/escrita de um dado compartilhado entre um `lock` e um `unlock` garante que apenas uma thread mexa naquele dado a cada momento

```c
pthread_mutex_lock(&mutex);
contador++;
```

