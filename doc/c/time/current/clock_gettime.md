**clock_gettime**

> `time.h` (POSIX)

O `clock_gettime` lê o valor atual de um dos relógios do sistema com precisão de nanossegundos, permitindo escolher entre o horário real, um contador monotônico que nunca volta para trás, ou o tempo de CPU gasto pelo processo ou pela thread

> Um relógio `monotônico` é um contador que só anda para frente, a partir de um ponto qualquer (normalmente o boot da máquina). Ele não diz que horas são, mas a diferença entre duas leituras é sempre o tempo real que passou, mesmo que alguém mude o relógio do sistema no meio

```c
int clock_gettime(clockid_t clock_id, struct timespec *tp);
```

- `clock_id`: qual relógio ler
	- `CLOCK_REALTIME`: o horário real (segundos desde o epoch, como o `time`), pode pular se o relógio for ajustado
	- `CLOCK_MONOTONIC`: contador que só anda para frente, o certo para medir intervalos
	- `CLOCK_PROCESS_CPUTIME_ID`: tempo de CPU gasto pelo processo inteiro (todas as threads)
	- `CLOCK_THREAD_CPUTIME_ID`: tempo de CPU gasto só pela thread atual
- `tp`: onde o resultado vai ser guardado, como segundos e nanossegundos

- Devolve `0` em caso de sucesso, ou `-1` em caso de erro (com o `errno` ajustado, por exemplo para um `clock_id` inválido)
- Faz parte do POSIX: funciona no Linux e no macOS (desde o 10.12), mas não existe no Windows
- A precisão real depende do hardware, mas é de nanossegundos ou poucos microssegundos nos sistemas atuais

```c
struct timespec agora;
clock_gettime(CLOCK_REALTIME, &agora);
printf("%lld.%09ld\n", (long long)agora.tv_sec, agora.tv_nsec);
// 1791136800.123456789
```

---

**Medindo quanto tempo algo levou**

```c
struct timespec inicio, fim;

clock_gettime(CLOCK_MONOTONIC, &inicio);
processar();
clock_gettime(CLOCK_MONOTONIC, &fim);

double ms = (fim.tv_sec - inicio.tv_sec) * 1000.0
          + (fim.tv_nsec - inicio.tv_nsec) / 1e6;

printf("levou %.3f ms\n", ms);
```

> Usar `CLOCK_REALTIME` para medir intervalos é um erro sutil: se o sistema sincronizar o relógio durante a medição, o resultado pode sair maior, menor ou até negativo. O `CLOCK_MONOTONIC` nunca tem esse problema

---

**Tempo de CPU x tempo real**

Uma função que espera (rede, disco, `sleep`) gasta tempo real mas quase nenhum tempo de CPU:

```c
struct timespec r0, r1, c0, c1;

clock_gettime(CLOCK_MONOTONIC, &r0);
clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &c0);

sleep(1);

clock_gettime(CLOCK_MONOTONIC, &r1);
clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &c1);

// tempo real: ~1.000 s
// tempo de CPU: ~0.000 s, o processo ficou parado
```

---

**Timestamp em milissegundos**

Formato comum em logs e APIs:

```c
int64_t agora_ms(void) {
  struct timespec t;
  clock_gettime(CLOCK_REALTIME, &t);
  return (int64_t)t.tv_sec * 1000 + t.tv_nsec / 1000000;
}
```

> Diferente do `time`, que só tem precisão de segundos, e do `clock`, que só mede tempo de CPU, o `clock_gettime` cobre todos os casos com precisão de nanossegundos. O antigo `gettimeofday` (microssegundos, só tempo real) é considerado obsoleto pelo POSIX e deve ser trocado por ele. Em código que precisa compilar também no Windows, o `timespec_get` do C11 é a alternativa padrão para o tempo real
