**Tutorial Prático: Contador Compartilhado com Mutex**

A baixo temos as funções da biblioteca `pthread` usadas para trabalhar com múltiplas threads em C: criar threads, esperar seu término, sincronizar acesso a dados compartilhados e coordenar threads entre si

> Programas que usam `pthread` precisam ser compilados com a flag `-pthread` (por exemplo, `gcc programa.c -pthread -o programa`), já que essas funções não fazem parte da biblioteca padrão do C, exigindo linkagem explícita com a biblioteca de threads

---

**Thread**

Uma thread é uma linha de execução dentro de um programa. Todo programa começa com uma única thread, a que roda o `main`, e pode criar outras para executar funções ao mesmo tempo que ela

> Um processo é o programa rodando, com a sua própria memória. As threads vivem dentro do processo e compartilham essa memória: as variáveis globais e tudo que foi alocado com `malloc` são vistos por todas elas. Cada thread só tem acesso a ver e modificar a própria pilha, ou seja, as variáveis locais da função que ela está executando

```text
programa
├── memória compartilhada  →  globais, heap (malloc)
├── thread main            →  pilha própria (variáveis locais do main)
├── thread 1               →  pilha própria (variáveis locais de incrementar)
└── thread 2               →  pilha própria (variáveis locais de incrementar)
```

- Compartilhar a memória é o que torna as threads úteis, porque elas trabalham sobre os mesmos dados simultaneamente sem precisar copiá-los

- É também o que as torna perigosas, ja que duas threads podem mexer no mesmo dado ao mesmo tempo

- A ordem em que as threads rodam é decidida pelo sistema operacional e muda a cada execução. Nunca conte com uma thread rodando antes da outra

**Veja na ordem**
- `doc/c/thread/pthread/functions/pthread_create.md`
- `doc/c/thread/pthread/functions/pthread_join.md`
- `doc/c/thread/pthread/functions/pthread_detach.md`
- `doc/c/thread/pthread/functions/pthread_self.md`
- `doc/c/thread/pthread/functions/pthread_exit.md`

---

**Condição de corrida**

Uma condição de corrida acontece quando duas threads acessam o mesmo dado ao mesmo tempo, pelo menos uma delas escreve nele, e o resultado final depende de qual chegou primeiro

O `contador++` parece uma única operação, mas o processador executa três passos separados:

```c
int tmp = contador;  // 1. lê o valor da memória
tmp = tmp + 1;       // 2. soma 1
contador = tmp;      // 3. grava o valor de volta
```

Se duas threads fazem isso ao mesmo tempo, uma pode ler o valor antes da outra gravar, e um dos incrementos se perde:

```text
contador = 5
thread 1 lê 5
thread 2 lê 5
thread 1 grava 6
thread 2 grava 6   →  dois incrementos, mas o contador só subiu 1
```

- O trecho de código que acessa o dado compartilhado e não pode ser executado por duas threads ao mesmo tempo se chama **seção crítica**

- O erro não aparece sempre. O programa pode funcionar em um teste e dar um valor errado no seguinte, o que torna esse tipo de bug difícil de encontrar

---

**Mutex**

Um mutex (de *mutual exclusion*, exclusão mútua) é uma trava que só uma thread consegue segurar por vez. Ele é usado para proteger a seção crítica: a thread trava o mutex antes de entrar e destrava ao sair

```c
pthread_mutex_lock(&mutex);    // trava. Se outra thread já travou, espera aqui até ela destravar
contador++;                    // seção crítica, só uma thread por vez passa por aqui
pthread_mutex_unlock(&mutex);  // destrava e libera a próxima thread que estava esperando
```

- O `pthread_mutex_lock` não falha quando o mutex está ocupado. Ele coloca a thread para esperar até o mutex ficar livre
- O mutex não sabe qual dado ele protege. É você que precisa travar o mesmo mutex em **todo** lugar que acessa aquele dado. Um acesso sem trava basta para a condição de corrida voltar
- Quem travou é quem destrava. Esquecer o `pthread_mutex_unlock` deixa todas as outras threads esperando para sempre (*deadlock*)
- Mantenha a seção crítica pequena. Enquanto uma thread segura o mutex, as outras ficam paradas, e o programa perde o ganho de rodar em paralelo

---

**Por que o mutex precisa ser iniciado**

O `pthread_mutex_t` é uma struct que guarda o estado da trava: se está travada, qual thread a segura e quais threads estão esperando. Declarar a variável só reserva o espaço na memória, e esse estado ainda não existe

- Uma variável local começa com lixo de memória. Usar um mutex nesse estado é comportamento indefinido, e o programa pode travar, deixar duas threads entrarem juntas ou funcionar por sorte
- O `pthread_mutex_init` preenche a struct com um estado válido de mutex destravado e aplica os atributos pedidos (`NULL` usa os atributos padrão)
- O mutex precisa ser iniciado **antes** de qualquer thread usá-lo, por isso o `pthread_mutex_init` vem antes do `pthread_create`
- Depois que todas as threads terminaram, o `pthread_mutex_destroy` libera o que o sistema reservou para o mutex. Ele só pode ser chamado com o mutex destravado e sem ninguém esperando por ele, por isso vem depois do `pthread_join`

Para um mutex global, existe a forma estática, que já declara a variável iniciada com os atributos padrão:

```c
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;  // dispensa o pthread_mutex_init
```

> O mutex resolve o acesso ao mesmo dado, mas não serve para uma thread esperar outra avisar que algo ficou pronto. Para isso existem as variáveis de condição (ver `../pthread_cond/summary.md`)

---

**Exemplo completo**

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

- **pthread_mutex_init** incia o mutex

- **pthread_create** dispara cada thread para rodar `incrementar` concorrentemente

- Cada thread usa **pthread_mutex_lock** e **pthread_mutex_unlock** para garantir que só uma delas consiga acessar a variavel `contador` por vez

- **pthread_join** espera todas as threads terminarem antes do `main` continuar

- **pthread_mutex_destroy** libera o mutex

