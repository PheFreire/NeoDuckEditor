**pthread_create**

> `pthread.h`

O `pthread_create` cria uma nova thread, que passa a executar concorrentemente com a thread que a criou

```c
#include <pthread.h>

int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                    void *(*start_routine)(void *), void *arg);
```

- `thread`: ponteiro para a variável que vai receber o identificador da nova thread
- `attr`: ponteiro para uma estrutura de atributos que controla detalhes como tamanho da pilha ou política de escalonamento; `NULL` para usar os atributos padrão
- `start_routine`: ponteiro para a função que a nova thread vai executar, que deve receber um `void *` e retornar um `void *`
- `arg`: o argumento que será passado para `start_routine` quando a thread começar a rodar

- Retorna `0` em caso de sucesso, ou um código de erro positivo em caso de falha; diferente da maioria das chamadas POSIX, o erro é o próprio valor de retorno, não é lido via `errno`
- Depois que `pthread_create` retorna com sucesso, não há garantia de ordem entre a nova thread e a thread que a criou; qualquer uma pode rodar primeiro
- Um mesmo `start_routine` pode ser reaproveitado para criar várias threads, cada uma recebendo seu próprio `arg`

```c
pthread_t thread;
pthread_create(&thread, NULL, incrementar, NULL);
```

