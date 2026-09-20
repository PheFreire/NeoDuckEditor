**pthread_exit**

> `pthread.h`

O `pthread_exit` termina imediatamente a thread que a chamou, de forma equivalente a um `return` dentro da função inicial da thread, mas podendo ser chamado de qualquer função executada por ela, não só na função de nível mais alto

```c
#include <pthread.h>

void pthread_exit(void *retval);
```

- `retval`: o valor que a thread terminada vai "retornar", recuperável por outra thread através do parâmetro `retval` de `pthread_join`

- Não retorna: nenhum código depois de `pthread_exit` roda naquela thread
- Se chamado pela thread principal (`main`), termina apenas essa thread, não o processo inteiro; as demais threads continuam rodando normalmente, diferente de uma chamada a `exit()`
- Chamar `pthread_exit(NULL)` dentro de uma função de thread tem o mesmo efeito prático de um `return NULL;` no final dela

```c
pthread_exit(NULL);
```

