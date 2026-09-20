**pthread_cond_broadcast**

> `pthread.h`

O `pthread_cond_broadcast` acorda todas as threads que estejam esperando em uma variável de condição, em vez de apenas uma

```c
#include <pthread.h>

int pthread_cond_broadcast(pthread_cond_t *cond);
```

- `cond`: a variável de condição a ser sinalizada para todas as threads em espera

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Útil quando mais de uma thread pode estar esperando pela mesma condição e todas precisam ter a chance de rechecá-la, e não só a próxima a ser escolhida pelo sistema
- Como cada thread acordada ainda precisa retravar o mesmo mutex antes de `pthread_cond_wait` retornar, elas continuam sendo liberadas uma de cada vez na prática, apenas todas são colocadas de volta na fila de disputa pelo mutex

```c
pthread_cond_broadcast(&cond);
```

