**pthread_self**

> `pthread.h`

O `pthread_self` devolve o identificador da própria thread que o chamou, o mesmo valor que o `pthread_create` gravou no `pthread_t` de quem criou essa thread

```c
#include <pthread.h>

pthread_t pthread_self(void);
```

- Não recebe parâmetros. A thread que ele identifica é sempre a que está executando a chamada

> Devolve o `pthread_t` da thread atual e nunca falha, então não existe código de erro para checar. Chamado dentro do `main`, devolve o identificador da thread principal

> O `pthread_t` é um tipo opaco. Dependendo do sistema ele pode ser um número ou um ponteiro para uma struct interna, por isso dois identificadores não devem ser comparados com `==`. Para saber se dois `pthread_t` são a mesma thread, use o `pthread_equal` (ver `pthread_equal.md`)

> Pelo mesmo motivo, não existe um jeito portátil de imprimir um `pthread_t` com `printf`. Quando você precisa mostrar qual thread está rodando, a forma portátil é dar a cada thread um número próprio pelo `arg` do `pthread_create`

> Ele serve para a thread fazer algo **consigo mesma** sem precisar receber o próprio identificador de fora, como se destacar com `pthread_detach(pthread_self())` (ver `pthread_detach.md`) ou descobrir se é a thread principal

> O identificador só é único enquanto a thread existe. Depois que ela termina e recebe `pthread_join` ou estava destacada, o sistema pode reaproveitar o mesmo valor para uma thread nova

---

```c
pthread_t id_atual = pthread_self();  // identificador da thread que está rodando esta linha
```

---

**A própria thread se destacando**

Sem o `pthread_self`, a thread precisaria receber o próprio identificador pelo `arg` para conseguir se destacar:

```c
void *tarefa(void *arg)
{
    // pthread_self devolve o identificador da própria thread
    pthread_detach(pthread_self());

    // ... trabalho da thread

    return NULL;
}
```

---

**Descobrindo se é a thread principal**

O `main` guarda o próprio identificador em uma variável global antes de criar as threads, e qualquer função pode comparar com ele depois:

```c
pthread_t thread_principal;

int main(void)
{
    // guardado antes de qualquer pthread_create, então as threads sempre leem o valor certo
    thread_principal = pthread_self();
}
```

```c
if (pthread_equal(pthread_self(), thread_principal)) {
    printf("sou a thread principal\n");
}
```

---

Uma mesma função de log chamada pelo `main` e por várias threads criadas em um `for`, que usa o `pthread_self` para saber quem a chamou:

```c
#include <stdio.h>
#include <pthread.h>

#define NUM_THREADS 3

pthread_t thread_principal;

// função comum, chamada tanto pelo main quanto pelas threads
void registrar(const char *mensagem)
{
    if (pthread_equal(pthread_self(), thread_principal)) {
        printf("[main] %s\n", mensagem);
    } else {
        printf("[thread] %s\n", mensagem);
    }
}

void *trabalhar(void *arg)
{
    // arg não é usado neste exemplo
    (void)arg;

    registrar("começou a trabalhar");
    return NULL;
}

int main(void)
{
    pthread_t threads[NUM_THREADS];

    // guarda o identificador do main antes de criar as threads
    thread_principal = pthread_self();
    registrar("criando as threads");

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, trabalhar, NULL);
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    registrar("todas as threads terminaram");
    return 0;
}
```

```text
[main] criando as threads
[thread] começou a trabalhar
[thread] começou a trabalhar
[thread] começou a trabalhar
[main] todas as threads terminaram
```

> A função `registrar` não recebe nenhum parâmetro dizendo quem a chamou. É o `pthread_self` dentro dela que devolve um valor diferente dependendo da thread que está executando a chamada

> O `thread_principal` é escrito antes do primeiro `pthread_create` e depois só é lido. Por isso as threads podem ler essa global sem mutex. Se o `main` escrevesse nela depois de criar as threads, haveria uma condição de corrida

> As threads sempre imprimem entre as duas linhas do `main`, porque a primeira roda antes do `pthread_create` e a última depois do `pthread_join`. Entre elas, a ordem das threads muda a cada execução
