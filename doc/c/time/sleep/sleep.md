**sleep**

> `unistd.h` (POSIX)

O `sleep` pausa a execução da thread atual por uma quantidade de segundos inteiros, liberando o processador para outros programas durante a espera

> Enquanto um programa "dorme", o sistema operacional não o executa: ele não gasta CPU e é acordado automaticamente quando o tempo termina. É bem diferente de um laço vazio esperando o tempo passar ("busy wait"), que deixa o processador ocupado em 100% sem fazer nada útil

```c
unsigned int sleep(unsigned int segundos);
```

- `segundos`: quanto tempo esperar, em segundos inteiros

- Devolve `0` se dormiu o tempo todo, ou a quantidade de segundos que faltavam se for acordado antes por um sinal (como o `Ctrl+C` tratado com `signal`)
- O tempo real de espera pode ser um pouco maior que o pedido, dependendo de quando o sistema volta a executar o programa
- Faz parte do POSIX (`unistd.h`), e não da `time.h` nem do padrão C. No Windows, o equivalente é `Sleep(milissegundos)`, de `windows.h`, com `S` maiúsculo e em milissegundos

```c
#include <unistd.h>

printf("esperando...\n");
sleep(2);
printf("pronto\n"); // 2 segundos depois
```

**Repetindo uma tarefa periodicamente**

```c
for (;;) {
  verificar_atualizacoes();
  sleep(60); // a cada minuto
}
```

> Esse laço não roda exatamente a cada 60 segundos: ele espera 60 segundos depois do fim de cada tarefa, então o tempo da própria tarefa se acumula. Para um intervalo preciso, calcula-se o próximo horário com `clock_gettime` e dorme-se só a diferença

**Contagem regressiva**

```c
for (int i = 3; i > 0; i--) {
  printf("%d...\n", i);
  sleep(1);
}
printf("vai!\n");
```

**Esperando menos de um segundo**

O `sleep` só aceita segundos inteiros. `sleep(0.5)` converte `0.5` para `0` e não espera nada. Para frações de segundo, use o `nanosleep`:

```c
struct timespec meio = {0, 500000000};
nanosleep(&meio, NULL); // 0.5 s
```

> O antigo `usleep` (microssegundos) ainda funciona no Linux e no macOS, mas foi removido do POSIX em 2008 e não deve ser usado em código novo

> Diferente do `nanosleep`, que aceita nanossegundos e informa exatamente quanto tempo faltou quando é interrompido, o `sleep` só trabalha com segundos inteiros. Ele é suficiente para esperas longas e simples, e o `nanosleep` para qualquer espera mais curta ou que precise ser precisa
