**Tutorial Prático: Produtor/Consumidor com Variável de Condição**

Um mutex protege dados compartilhados, mas não resolve sozinho o problema de uma thread precisar esperar até que uma determinada condição se torne verdadeira (por exemplo, "até que exista um item para consumir"). Fazer essa espera girando em loop e checando a condição repetidamente (*busy waiting*) desperdiça CPU; as variáveis de condição resolvem isso, colocando a thread para dormir até ser avisada

```c
#include <stdio.h>
#include <pthread.h>

int pronto = 0;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;

void *produtor(void *arg) {
    pthread_mutex_lock(&mutex);
    pronto = 1;
    pthread_cond_signal(&cond);
    pthread_mutex_unlock(&mutex);
    return NULL;
}

void *consumidor(void *arg) {
    pthread_mutex_lock(&mutex);
    while (!pronto) {
        pthread_cond_wait(&cond, &mutex);
    }
    pthread_mutex_unlock(&mutex);
    printf("consumidor: dado pronto!\n");
    return NULL;
}

int main() {
    pthread_t t_produtor, t_consumidor;

    pthread_create(&t_consumidor, NULL, consumidor, NULL);
    pthread_create(&t_produtor, NULL, produtor, NULL);

    pthread_join(t_produtor, NULL);
    pthread_join(t_consumidor, NULL);

    pthread_cond_destroy(&cond);
    pthread_mutex_destroy(&mutex);
    return 0;
}
```

O `consumidor` trava o mutex e entra em `pthread_cond_wait`, que libera o mutex e dorme até ser avisado; quando o `produtor` seta `pronto = 1` e chama `pthread_cond_signal`, o `consumidor` acorda, retrava o mutex automaticamente e volta a checar a condição no `while`. Esse exemplo também usa `PTHREAD_MUTEX_INITIALIZER` e `PTHREAD_COND_INITIALIZER`, as versões estáticas de inicialização, como alternativa a chamar `pthread_mutex_init`/`pthread_cond_init` explicitamente
