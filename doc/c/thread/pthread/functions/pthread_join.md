**pthread_join**

> `pthread.h`

O `pthread_join` bloqueia a thread chamadora até que a thread indicada termine sua execução

```c
#include <pthread.h>

int pthread_join(pthread_t thread, void **retval);
```

- `thread`: o identificador da thread que você quer esperar, o mesmo que o `pthread_create` gravou

- `retval`: ponteiro para onde o valor de retorno da thread terminada será escrito. Pode ser `NULL` se esse valor não for necessário

> Retorna `0` em caso de sucesso, ou um código de erro em caso de falha (`ESRCH` quando o identificador não corresponde a nenhuma thread e `EDEADLK` quando a thread tenta esperar ela mesma)

> O valor devolvido pelo `pthread_join` diz só se a espera funcionou. O resultado do trabalho da thread chega pelo parâmetro `retval`

> Só funciona em threads "joinable" (o estado padrão ao criar uma thread). Uma thread destacada não pode mais ser esperada com `pthread_join`

> Assim como um `fd` aberto precisa de um `close`, toda thread criada como joinable deveria ser esperada com `pthread_join` (ou destacada com `pthread_detach`), evitando deixar recursos presos até o processo terminar. Se você não precisa esperar por ela, use `pthread_detach` (ver `functions/pthread_detach.md`)

> Cada thread só pode receber um `pthread_join`. Chamar de novo para a mesma thread é comportamento indefinido

> Nunca devolva o endereço de uma variável local da função da thread. A pilha da thread deixa de existir quando ela termina, e o `pthread_join` recebe um endereço que aponta para memória inválida. Devolva memória alocada com `malloc`, que o `main` libera com `free` depois de usar

---

```c
pthread_t t;                                  // identificador da thread
pthread_create(&t, NULL, incrementar, NULL);  // t passa a rodar incrementar(NULL)
pthread_join(t, NULL);                        // o main fica parado até t terminar
```

---

Criando várias threads em um `for`, mandando um número diferente para cada uma e recebendo os resultados de volta pelo `pthread_join`:

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NUM_THREADS 4

void *quadrado(void *arg) 
{
    // converte o void * de volta para int * e lê o valor
    int n = *(int *)arg;
    
    // memória heap continua existindo depois que a thread termina
    int *resultado = malloc(sizeof(int));
    *resultado = n * n;

    // esse endereço chega no pthread_join
    return resultado;
}

int main(void) 
{
    pthread_t threads[NUM_THREADS];

    // cada thread recebe o endereço do seu próprio elemento do vetor
    int numeros[NUM_THREADS] = {2, 3, 4, 5};

    // cria todas as threads, que passam a rodar ao mesmo tempo
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, quadrado, &numeros[i]);
    }

    // espera cada thread na ordem do vetor e recolhe o que a func retornou
    for (int i = 0; i < NUM_THREADS; i++) {
        void *retorno;
        pthread_join(threads[i], &retorno);

        int *r = retorno;
        printf("%d ao quadrado: %d\n", numeros[i], *r);
        free(r);
    }

    return 0;
}
```

```text
2 ao quadrado: 4
3 ao quadrado: 9
4 ao quadrado: 16
5 ao quadrado: 25
```

> A criação e a espera ficam em dois `for` separados. Chamar o `pthread_join` dentro do mesmo `for` que cria as threads faria o `main` esperar cada thread terminar antes de criar a próxima, e elas rodariam uma de cada vez em vez de ao mesmo tempo

> Passar `&i` no lugar de `&numeros[i]` faria todas as threads apontarem para a mesma variável, que continua mudando enquanto o `for` roda. Cada thread poderia ler um valor diferente do esperado, ou o mesmo valor repetido

> A saída sai sempre na mesma ordem porque o `printf` está no `for` do `pthread_join`, que segue a ordem do vetor. As threads podem ter terminado em qualquer ordem
