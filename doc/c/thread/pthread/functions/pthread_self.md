**pthread_self**

> `pthread.h`

O `pthread_self` retorna o identificador da própria thread que o chamou

```c
#include <pthread.h>

pthread_t pthread_self(void);
```

- Não recebe parâmetros

- Retorna o `pthread_t` da thread atual
- Útil para logging/depuração, ou para uma thread se identificar quando várias threads compartilham a mesma função inicial

```c
pthread_t id_atual = pthread_self();
```

