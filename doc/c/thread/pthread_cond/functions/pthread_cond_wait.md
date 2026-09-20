**pthread_cond_wait**

> `pthread.h`

O `pthread_cond_wait` coloca a thread chamadora para dormir esperando por um sinal em uma variável de condição, liberando o mutex associado enquanto espera

```c
#include <pthread.h>

int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
```

- `cond`: a variável de condição a ser esperada
- `mutex`: o mutex que a thread chamadora já deve manter travado antes de chamar essa função

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Ao ser chamado, libera `mutex` e coloca a thread para dormir de forma atômica; ao ser acordado (por `pthread_cond_signal`/`pthread_cond_broadcast`), retrava `mutex` automaticamente antes de retornar
- Deve sempre ser chamado dentro de um laço `while` que recheca a condição real (e não um `if`), porque podem ocorrer "acordadas espúrias" (a thread acorda sem que o sinal tenha de fato ocorrido) e porque outra thread pode ter consumido a condição antes dela
- Existe a variante `pthread_cond_timedwait`, que aceita um tempo limite de espera, evitando bloquear a thread indefinidamente

```c
pthread_mutex_lock(&mutex);
while (!pronto) {
    pthread_cond_wait(&cond, &mutex);
}
pthread_mutex_unlock(&mutex);
```

