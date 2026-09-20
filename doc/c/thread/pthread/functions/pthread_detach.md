**pthread_detach**

> `pthread.h`

O `pthread_detach` marca uma thread como destacada, fazendo seus recursos serem liberados automaticamente assim que ela terminar, sem que outra thread precise chamar `pthread_join`

```c
#include <pthread.h>

int pthread_detach(pthread_t thread);
```

- `thread`: o identificador da thread a ser destacada

- Retorna `0` em caso de sucesso, ou um código de erro em caso de falha
- Depois de destacada, chamar `pthread_join` sobre essa thread se torna um erro
- Útil para threads "dispara e esquece", cujo valor de retorno não importa e que não precisam ser esperadas explicitamente

```c
pthread_detach(thread);
```

