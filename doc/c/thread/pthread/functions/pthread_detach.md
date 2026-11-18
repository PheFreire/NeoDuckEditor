**pthread_detach**

> `pthread.h`

O `pthread_detach` marca uma thread como destacada, fazendo o sistema liberar os recursos dela sozinho assim que ela terminar, sem que nenhuma outra thread precise chamar o `pthread_join`

```c
#include <pthread.h>

int pthread_detach(pthread_t thread);
```

- `thread`: o identificador da thread que você quer destacar, o mesmo que o `pthread_create` gravou. A própria thread também pode se destacar passando o `pthread_self()` (ver `pthread_self.md`)

> Devolve `0` em caso de sucesso, ou um código de erro em caso de falha (`EINVAL` quando a thread já foi destacada e `ESRCH` quando o identificador não corresponde a nenhuma thread). Assim como no `pthread_create`, o erro vem no próprio valor devolvido, e o `errno` não é alterado

> O `pthread_detach` não interrompe a thread nem espera ela terminar. A chamada volta imediatamente e a thread segue rodando como antes. A única diferença aparece quando ela termina: uma thread joinable fica com os recursos presos até alguém chamar o `pthread_join`, e uma thread destacada basicamente ganha uma flag que indica que a thread dever ter esses recursos liberados pelo sistema assim que acaba

> Depois de destacada, a thread não pode mais receber `pthread_join`, e não existe como voltar atrás. O valor que a função da thread devolve no `return` é descartado, então qualquer resultado precisa sair por outro caminho, como um `printf`, um arquivo ou uma variável compartilhada protegida por mutex

> Cada thread só pode ser destacada uma vez, e uma thread que já recebeu `pthread_join` não pode ser destacada. Toda thread criada como joinable precisa de um `pthread_join` ou um `pthread_detach` (ver `pthread_join.md`)

> Destacar não protege a thread do fim do `main`. Se o `main` chegar no `return 0`, o processo inteiro termina e as threads destacadas morrem no meio do trabalho. Para o `main` sair sem matar as outras threads, termine ele com `pthread_exit(NULL)` (ver `pthread_exit.md`)

> Como ninguém espera a thread destacada, o `arg` que ela recebe precisa continuar válido enquanto ela roda. Mandar o endereço de uma variável local de uma função que já terminou faz a thread ler memória inválida. Aloque o `arg` com `malloc` e deixe a própria thread liberar com `free`

---

```c
// identificador da thread
pthread_t t;

// t passa a rodar tarefa(NULL)
pthread_create(&t, NULL, tarefa, NULL);

// ninguém espera por t, e o main continua
pthread_detach(t);
```

---

**A própria thread se destacando**

Quando quem cria a thread não quer cuidar dela, a função da thread pode se destacar sozinha logo no começo:

```c
void *tarefa(void *arg)
{
    // pthread_self devolve o identificador da própria thread
    pthread_detach(pthread_self());

    return NULL;
}
```

---

**Criando a thread já destacada**

Também dá para criar a thread já destacada, sem precisar chamar o `pthread_detach` depois. Para isso, você prepara um `pthread_attr_t` com o estado `PTHREAD_CREATE_DETACHED` e passa ele no parâmetro `attr` do `pthread_create`:

```c
pthread_t t;
pthread_attr_t attr;

pthread_attr_init(&attr);
pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);  // já nasce destacada

pthread_create(&t, &attr, tarefa, NULL);
pthread_attr_destroy(&attr);  // o attr só é lido na criação e pode ser destruído logo depois
```

> Essa forma evita uma janela entre o `pthread_create` e o `pthread_detach` em que a thread ainda é joinable. (Na prática as duas formas funcionam, e o `pthread_detach` depois do `pthread_create` é a mais comum)

---

Criando várias threads destacadas em um `for`, cada uma recebendo o seu próprio número alocado no heap:

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define NUM_THREADS 4

void *avisar(void *arg)
{
    // a thread é dona do arg e libera assim que leu o valor
    int id = *(int *)arg;
    free(arg);

    printf("thread %d terminou o trabalho\n", id);

    // ninguém vai fazer pthread_join, então esse valor é descartado
    return NULL;
}

int main(void)
{
    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_t t;

        // cada thread recebe o seu próprio int, que continua existindo depois que o for avança
        int *id = malloc(sizeof(int));
        *id = i;

        pthread_create(&t, NULL, avisar, id);

        // a partir daqui ninguém precisa esperar por t, e o for já cria a próxima
        pthread_detach(t);
    }

    // termina só a thread main, e o processo continua até as threads destacadas acabarem
    pthread_exit(NULL);
}
```

```text
thread 0 terminou o trabalho
thread 2 terminou o trabalho
thread 1 terminou o trabalho
thread 3 terminou o trabalho
```

> A ordem da saída muda a cada execução. Diferente do exemplo com `pthread_join`, aqui não existe um `for` que espera as threads na ordem do vetor, então cada uma imprime quando termina

> O `pthread_t t` pode ser uma variável local do `for` porque, depois do `pthread_detach`, o identificador não é mais usado. Com `pthread_join`, os identificadores precisariam ficar guardados em um vetor até a espera

> Trocar o `pthread_exit(NULL)` por um `return 0` pode fazer o programa terminar antes de alguma thread imprimir, e a saída sai incompleta
