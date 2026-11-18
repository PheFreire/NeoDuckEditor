**pthread_exit**

> `pthread.h`

O `pthread_exit` termina imediatamente a thread que o chamou, como um `return` na função inicial da thread, mas pode ser chamado de qualquer função que essa thread esteja executando, e não só da função que o `pthread_create` recebeu

```c
#include <pthread.h>

void pthread_exit(void *retval);
```

- `retval`: o valor que a thread devolve ao terminar. É esse valor que outra thread recebe no parâmetro `retval` do `pthread_join` (ver `pthread_join.md`). `NULL` quando ninguém precisa de resultado

> Não devolve nada e nunca volta para quem chamou. Nenhuma linha depois do `pthread_exit` roda naquela thread

> Dentro da função inicial da thread, `pthread_exit(valor)` e `return valor` têm o mesmo efeito. A diferença aparece em funções auxiliares: um `return` dentro delas só volta para quem as chamou, e o `pthread_exit` encerra a thread inteira dali mesmo

> Chamado no `main`, termina só a thread principal. As outras threads continuam rodando, e o processo só acaba quando a última delas termina. Já o `return` no `main` e o `exit` terminam o processo inteiro, matando todas as threads no meio do trabalho

> As variáveis locais da thread deixam de existir quando ela termina, então o `retval` não pode apontar para elas. Devolva memória alocada com `malloc` ou um número guardado dentro do próprio `void *`

> O `pthread_exit` termina só a execução da thread. Ele não destrava os mutex que ela estava segurando, não fecha arquivos e não libera a memória que ela alocou. Sair com um mutex travado deixa as outras threads esperando por ele para sempre (*deadlock*)

> Se a thread estava destacada, o `retval` é descartado, porque ninguém vai chamar o `pthread_join` para recebê-lo (ver `pthread_detach.md`)

| | o que termina | as outras threads |
|---|---|---|
| `return` na função da thread | só essa thread | continuam rodando |
| `pthread_exit` em qualquer função da thread | só essa thread | continuam rodando |
| `pthread_exit` no `main` | só a thread principal | continuam rodando, e o processo espera por elas |
| `return` no `main` ou `exit` | o processo inteiro | morrem junto |

---

```c
pthread_exit(NULL);  // termina a thread atual sem devolver resultado
```

---

**Saindo de dentro de uma função auxiliar**

Uma função chamada pela thread pode encerrar a thread inteira, sem precisar devolver um erro para cada função acima dela:

```c
void conectar(void)
{
    if (!servidor_disponivel()) {
        // encerra a thread aqui, e quem chamou conectar não continua
        pthread_exit(NULL);
    }
}

void *tarefa(void *arg)
{
    conectar();

    // só chega aqui se conectar não encerrou a thread
    enviar_dados();
    return NULL;
}
```

---

**O main saindo sem matar as threads**

Com threads destacadas não existe `pthread_join` para segurar o `main`. Terminar com `pthread_exit` deixa elas acabarem o trabalho:

```c
int main(void)
{
    pthread_t t;
    pthread_create(&t, NULL, tarefa, NULL);
    pthread_detach(t);

    // termina só o main, e o processo continua até t acabar
    pthread_exit(NULL);
}
```

---

Várias threads criadas em um `for`, em que uma função auxiliar usa o `pthread_exit` para encerrar a thread quando recebe um valor inválido:

```c
#include <stdio.h>
#include <stdint.h>
#include <pthread.h>

#define NUM_THREADS 4

// função auxiliar: encerra a thread inteira se o valor for inválido
int validar(int n)
{
    if (n < 0) {
        // termina a thread aqui, sem voltar para dobrar
        pthread_exit((void *)(intptr_t)-1);
    }
    return n;
}

void *dobrar(void *arg)
{
    int n = validar(*(int *)arg);

    // só chega aqui se validar não encerrou a thread
    return (void *)(intptr_t)(n * 2);
}

int main(void)
{
    pthread_t threads[NUM_THREADS];
    int numeros[NUM_THREADS] = {5, -3, 10, 7};

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, dobrar, &numeros[i]);
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        void *retorno;
        pthread_join(threads[i], &retorno);

        // o void * carrega um número, e não um endereço
        int resultado = (int)(intptr_t)retorno;

        if (resultado == -1) {
            printf("%d: valor inválido\n", numeros[i]);
        } else {
            printf("%d dobrado: %d\n", numeros[i], resultado);
        }
    }

    return 0;
}
```

```text
5 dobrado: 10
-3: valor inválido
10 dobrado: 20
7 dobrado: 14
```

> A thread do `-3` termina dentro de `validar`, e o `return` de `dobrar` nunca roda. Mesmo assim o `pthread_join` recebe o valor normalmente, porque para ele não importa se a thread saiu por `return` ou por `pthread_exit`

> O `(void *)(intptr_t)` guarda um número inteiro dentro do próprio `void *`, sem alocar memória. O `intptr_t`, de `stdint.h`, é um inteiro do mesmo tamanho de um ponteiro, o que garante que o número cabe e volta igual no `(int)(intptr_t)`. Serve para números pequenos. Para resultados maiores ou structs, devolva memória alocada com `malloc`

> Esse exemplo usa `-1` como sinal de erro, então nenhum resultado válido pode ser `-1`. Aqui os valores aceitos nunca são negativos, e o dobro deles também não
