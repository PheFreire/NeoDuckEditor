**timespec_get**

> `time.h` (C11)

O `timespec_get` preenche uma `struct timespec` com o horário atual em segundos e nanossegundos, sendo a alternativa do padrão C ao `clock_gettime(CLOCK_REALTIME)` do POSIX, disponível também fora de sistemas Unix

> Por fazer parte do padrão C desde o C11, o `timespec_get` funciona em qualquer compilador que siga o padrão, incluindo o MSVC no Windows, onde o `clock_gettime` não existe

```c
int timespec_get(struct timespec *ts, int base);
```

- `ts`: onde o horário atual vai ser guardado
- `base`: a referência de tempo usada. O padrão só exige `TIME_UTC`, que é o tempo de calendário (segundos desde o epoch, em UTC)

- Devolve o próprio valor de `base` em caso de sucesso, ou `0` em caso de falha
- O resultado é equivalente ao do `clock_gettime(CLOCK_REALTIME, ...)`, então também pode pular se o relógio do sistema for ajustado
- No C23 foi adicionado o `TIME_MONOTONIC` (opcional, nem toda biblioteca suporta) e o `timespec_getres`, que informa a precisão do relógio

```c
struct timespec agora;

if (timespec_get(&agora, TIME_UTC) != TIME_UTC) {
  // falhou
}

printf("%lld.%09ld\n", (long long)agora.tv_sec, agora.tv_nsec);
// 1791136800.123456789
```

**Timestamp em milissegundos, portável**

```c
int64_t agora_ms(void) {
  struct timespec t;
  timespec_get(&t, TIME_UTC);
  return (int64_t)t.tv_sec * 1000 + t.tv_nsec / 1000000;
}
```

**Data e hora com milissegundos**

Como o `tv_sec` é um `time_t`, ele pode ser passado direto para o `localtime`, e os milissegundos vêm do `tv_nsec`:

```c
struct timespec agora;
timespec_get(&agora, TIME_UTC);

char texto[32];
strftime(texto, sizeof(texto), "%H:%M:%S", localtime(&agora.tv_sec));
printf("%s.%03ld\n", texto, agora.tv_nsec / 1000000);
// 15:00:00.123
```

> Diferente do `clock_gettime`, que oferece vários relógios (monotônico, CPU), o `timespec_get` só garante o tempo real (`TIME_UTC`). Ele serve para registrar quando algo aconteceu com mais precisão que o `time`, mas para medir duração em código POSIX o `clock_gettime(CLOCK_MONOTONIC)` continua sendo a melhor escolha
