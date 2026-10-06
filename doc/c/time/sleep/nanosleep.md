**nanosleep**

> `time.h` (POSIX)

O `nanosleep` pausa a execução da thread atual por um intervalo definido em segundos e nanossegundos, permitindo esperas curtas como alguns milissegundos, e informa quanto tempo faltava caso seja interrompido antes do fim

> Um `sinal` é uma notificação que o sistema envia ao processo, como o `SIGINT` gerado pelo `Ctrl+C`. Se o processo tratar esse sinal, uma espera em andamento é interrompida para que o tratador rode, e a função de espera volta mais cedo, sinalizando isso com o erro `EINTR`

```c
int nanosleep(const struct timespec *pedido, struct timespec *restante);
```

- `pedido`: quanto tempo esperar. `tv_nsec` precisa estar entre `0` e `999999999`
- `restante`: se não for `NULL` e a espera for interrompida, recebe quanto tempo ainda faltava

- Devolve `0` se dormiu o tempo todo
- Devolve `-1` em caso de erro, com o `errno` ajustado para `EINTR` (interrompido por um sinal) ou `EINVAL` (`tv_nsec` fora do intervalo)
- A espera real pode ser um pouco maior que a pedida, pois o sistema arredonda para a precisão do seu relógio e precisa voltar a agendar o programa
- Faz parte do POSIX: funciona no Linux e no macOS, mas não no Windows

```c
#include <time.h>

struct timespec espera = {0, 100 * 1000000}; // 100 ms
nanosleep(&espera, NULL);
```

---

**Função para dormir em milissegundos**

```c
void dormir_ms(long ms) {
  struct timespec t;
  t.tv_sec = ms / 1000;
  t.tv_nsec = (ms % 1000) * 1000000;
  nanosleep(&t, NULL);
}

dormir_ms(1500); // 1.5 s, tv_sec == 1 e tv_nsec == 500000000
```

> Passar `1500 ms` direto como `tv_nsec = 1500000000` é inválido, pois passa de `999999999`. É preciso separar a parte inteira em `tv_sec`, como acima

---

**Dormindo o tempo todo mesmo com sinais**

Se a espera for interrompida, o `restante` já vem preenchido, e basta chamar de novo com ele:

```c
#include <errno.h>

void dormir_completo(struct timespec t) {
  while (nanosleep(&t, &t) == -1 && errno == EINTR) {
    // interrompido: t agora contém o tempo restante, tenta de novo
  }
}
```

---

**Laço com taxa fixa (como um jogo a 60 FPS)**

Medindo quanto tempo cada volta levou e dormindo só o que falta para completar o intervalo:

```c
const long frame_ns = 1000000000 / 60; // ~16.6 ms

for (;;) {
  struct timespec inicio, fim;
  clock_gettime(CLOCK_MONOTONIC, &inicio);

  atualizar();
  desenhar();

  clock_gettime(CLOCK_MONOTONIC, &fim);
  long gasto = (fim.tv_sec - inicio.tv_sec) * 1000000000L + (fim.tv_nsec - inicio.tv_nsec);

  if (gasto < frame_ns) {
    struct timespec resto = {0, frame_ns - gasto};
    nanosleep(&resto, NULL);
  }
}
```

> Para ainda mais precisão, o `clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, ...)` (Linux) dorme até um instante absoluto, em vez de por um intervalo, evitando que pequenos atrasos se acumulem a cada volta

> Diferente do `sleep`, que só aceita segundos inteiros e é da `unistd.h`, o `nanosleep` aceita frações de segundo, está na `time.h` e informa o tempo restante quando interrompido. No C11 existe também o `thrd_sleep`, de `threads.h`, com a mesma assinatura e a vantagem de ser do padrão C, mas com suporte menor entre as bibliotecas (o macOS não tem)
