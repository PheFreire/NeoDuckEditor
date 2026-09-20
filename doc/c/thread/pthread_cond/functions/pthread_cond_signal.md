**pthread_cond_signal**

> `pthread.h`

O `pthread_cond_signal` acorda uma das threads que estejam esperando em uma variável de condição, se houver alguma

```c
#include <pthread.h>

int pthread_cond_signal(pthread_cond_t *cond);
```

- `cond`: a variável de condição a ser sinalizada

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Se nenhuma thread estiver esperando em `cond` no momento da chamada, o sinal simplesmente se perde; ele não fica "guardado" para uma futura chamada a `pthread_cond_wait`
- Não é obrigatório manter o mutex travado ao chamar `pthread_cond_signal`, mas fazer isso (como no exemplo do produtor) evita certas condições de corrida entre o sinal e a checagem da condição por quem está esperando

```c
pthread_mutex_lock(&mutex);
pronto = 1;
pthread_cond_signal(&cond);
pthread_mutex_unlock(&mutex);
```

