**Tutorial Prático: Contador Compartilhado com Mutex**

A baixo temos as funções da biblioteca `pthread` usadas para trabalhar com múltiplas threads em C: criar threads, esperar seu término, sincronizar acesso a dados compartilhados e coordenar threads entre si

> Programas que usam `pthread` precisam ser compilados com a flag `-pthread` (por exemplo, `gcc programa.c -pthread -o programa`), já que essas funções não fazem parte da biblioteca padrão do C, exigindo linkagem explícita com a biblioteca de threads

Exemplo mínimo e completo: várias threads incrementando um contador compartilhado, protegido por um mutex para evitar condições de corrida

```c
#include <stdio.h>
#include <pthread.h>

#define NUM_THREADS 4
#define INCREMENTOS 100000

int contador = 0;
pthread_mutex_t mutex;

void *incrementar(void *arg) {
    for (int i = 0; i < INCREMENTOS; i++) {
        pthread_mutex_lock(&mutex);
        contador++;
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

int main() {
    pthread_t threads[NUM_THREADS];

    pthread_mutex_init(&mutex, NULL);

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_create(&threads[i], NULL, incrementar, NULL);
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        pthread_join(threads[i], NULL);
    }

    pthread_mutex_destroy(&mutex);

    printf("contador final: %d\n", contador);
    return 0;
}
```

O fluxo é: `pthread_mutex_init` prepara o mutex, `pthread_create` dispara cada thread para rodar `incrementar` concorrentemente, cada thread usa `pthread_mutex_lock`/`pthread_mutex_unlock` para garantir que só uma delas mexa em `contador` por vez, `pthread_join` espera todas terminarem antes do `main` continuar, e `pthread_mutex_destroy` libera o mutex no final. Sem o mutex, duas threads poderiam ler o mesmo valor de `contador` ao mesmo tempo e uma das incrementações se perderia.


