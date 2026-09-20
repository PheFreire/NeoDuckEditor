**pthread_equal**

> `pthread.h`

O `pthread_equal` compara dois identificadores de thread, verificando se eles se referem à mesma thread

```c
#include <pthread.h>

int pthread_equal(pthread_t t1, pthread_t t2);
```

- `t1` e `t2`: os dois identificadores de thread a serem comparados

- Retorna um valor diferente de zero se `t1` e `t2` forem a mesma thread, ou `0` caso contrário
- Necessário porque `pthread_t` não tem um tipo garantido pela POSIX (pode ser um inteiro ou uma struct, dependendo da implementação), então comparar com `==` diretamente não é portátil

```c
if (pthread_equal(pthread_self(), thread_principal)) {
    printf("sou a thread principal\n");
}
```

