**pthread_create**

> `pthread.h`

O `pthread_create` cria uma nova thread e faz ela começar a executar uma função, enquanto a thread que a criou continua rodando a linha seguinte sem esperar

```c
#include <pthread.h>

int pthread_create(
    pthread_t *thread, 
    const pthread_attr_t *attr,
    void *(*start_routine)(void *), 
    void *arg
);
```

- `thread`: ponteiro para a variável que vai receber o identificador da nova thread. (O `pthread_create` grava nela o identificador da thread criada, e é esse identificador que você passa depois para o `pthread_join`)

- `attr`: ponteiro para uma estrutura de atributos que controla detalhes como tamanho da pilha ou ou se ela pode receber `pthread_join`. `NULL` usa os atributos padrão, e a thread pode receber `pthread_join`

- `start_routine`: ponteiro para a função que a nova thread vai executar, que deve receber um `void *` e retornar um `void *`. (Passe a função sem os parenteses de execução pois o que vai é o endereço da função, e não o resultado de uma chamada)

- `arg`: o valor que a função recebe no parâmetro `arg`. Como o tipo é `void *`, dá para mandar o endereço de qualquer coisa: um `int`, uma struct com vários campos, um vetor. `NULL` quando a função não precisa de nada


> Retorna `0` em caso de sucesso, ou um código de erro positivo em caso de falha. Diferente da maioria das chamadas POSIX, o erro é o próprio valor de retorno, não é lido via `errno`

> Depois que `pthread_create` retorna com sucesso, não há garantia de ordem entre a nova thread e a thread que a criou. Qualquer uma pode rodar primeiro

> Um mesmo `start_routine` pode ser reaproveitado para criar várias threads, cada uma recebendo seu próprio `arg`

> O código de erro vem no próprio valor devolvido, e o `errno` não é alterado. Por isso o `perror` não mostra a mensagem certa, e o jeito é passar o valor devolvido para o `strerror`

- O `pthread_join` faz a thread que o chamou esperar outra terminar. Sem ele o `main` poderia chegar no `return 0` antes das threads acabarem, e o processo inteiro terminaria junto com o `main`, matando as threads no meio do trabalho

- O valor devolvido pela função executada pela thread pode ser recolhido pelo `pthread_join`

```c
pthread_t t;                                  // identificador da thread
pthread_create(&t, NULL, incrementar, NULL);  // t passa a rodar incrementar(NULL)
pthread_join(t, NULL);                        // o main fica parado até t terminar
```
