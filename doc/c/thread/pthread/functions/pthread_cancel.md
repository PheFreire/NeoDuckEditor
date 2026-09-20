**pthread_cancel**

> `pthread.h`

O `pthread_cancel` envia um pedido de cancelamento para uma thread, solicitando que ela termine antes de concluir naturalmente sua execução

```c
#include <pthread.h>

int pthread_cancel(pthread_t thread);
```

- `thread`: o identificador da thread a ser cancelada

- Retorna `0` em caso de sucesso, indicando apenas que o pedido foi entregue, e um código de erro em caso de falha
- O cancelamento não é necessariamente imediato: por padrão, só acontece em determinados pontos de cancelamento (como chamadas bloqueantes), a menos que a thread tenha configurado cancelamento assíncrono
- Deve ser usado com cuidado, pois cancelar uma thread no meio de uma seção crítica (por exemplo, com um mutex travado) pode deixar recursos compartilhados em estado inconsistente, já que o `unlock` correspondente pode nunca rodar

```c
pthread_cancel(thread);
```

