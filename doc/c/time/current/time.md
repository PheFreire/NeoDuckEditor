**time**

> `time.h`

O `time` devolve o instante atual como um `time_t`, ou seja, a quantidade de segundos desde `1970-01-01 00:00:00 UTC`, sendo a forma mais simples de saber "que horas são agora" em C

> O valor devolvido é o tempo de calendário do sistema, com precisão de segundos e sem fuso horário. Para mostrar como data e hora legíveis, ele precisa ser convertido com `localtime` ou `gmtime` e formatado com `strftime`

```c
time_t time(time_t *t);
```

- `t`: se não for `NULL`, o mesmo valor devolvido também é guardado em `*t`. Normalmente se passa `NULL` e usa-se só o retorno

- Devolve o instante atual como `time_t`, ou `(time_t)-1` se o relógio não estiver disponível (muito raro em sistemas comuns)
- A precisão é de segundos: duas chamadas dentro do mesmo segundo devolvem o mesmo valor
- Acompanha o relógio do sistema, então pode "pular" para frente ou para trás se o horário for ajustado manualmente ou por sincronização (NTP)

```c
time_t agora = time(NULL);
printf("%lld\n", (long long)agora); // por exemplo 1791136800

time_t t;
time(&t); // forma antiga, equivalente
```

---

**Mostrando a data e hora atuais**

```c
time_t agora = time(NULL);
struct tm *local = localtime(&agora);

char texto[64];
strftime(texto, sizeof(texto), "%d/%m/%Y %H:%M:%S", local);
printf("%s\n", texto); // 04/10/2026 15:00:00
```

---

**Semente para números aleatórios**

Um uso clássico é inicializar o `rand` com um valor diferente a cada execução:

```c
#include <stdlib.h>

srand((unsigned int)time(NULL));
int dado = rand() % 6 + 1;
```

> Como o valor muda só uma vez por segundo, dois programas iniciados no mesmo segundo geram a mesma sequência. Para qualquer uso de segurança, o `rand` não serve, independente da semente

---

**Verificando se algo expirou**

```c
time_t criado_em = time(NULL);
time_t validade = 30 * 60; // 30 minutos

// mais tarde...
if (time(NULL) - criado_em > validade) {
  // sessão expirada
}
```

> Diferente do `clock_gettime`, que oferece precisão de nanossegundos e um relógio monotônico, o `time` só tem precisão de segundos e segue o relógio do sistema. Ele é ideal para registrar datas, mas para medir quanto tempo algo demorou, use `clock_gettime(CLOCK_MONOTONIC)`
