**time_t**

> `time.h`

O `time_t` é o tipo usado para representar um instante no tempo como um único número, que no Linux, no macOS e em praticamente todo sistema atual é a quantidade de segundos que se passaram desde 1º de janeiro de 1970, à meia-noite em UTC

> Esse instante de referência, `1970-01-01 00:00:00 UTC`, é chamado de `epoch` (ou Unix epoch), e o número de segundos desde ele é chamado de `timestamp` Unix. O valor `0` é o próprio epoch, valores negativos são datas anteriores a 1970

```c
typedef /* tipo inteiro, normalmente long ou long long */ time_t;
```

- O padrão C só garante que é um tipo numérico. O POSIX garante que conta segundos desde o epoch, como inteiro
- Em sistemas de 64 bits atuais tem 8 bytes, o suficiente para cerca de 292 bilhões de anos
- Não guarda frações de segundo. Para isso existe a `struct timespec`
- Não tem fuso horário: o mesmo instante tem o mesmo `time_t` em qualquer lugar do mundo

```c
time_t agora = time(NULL);  // por exemplo 1791136800
time_t epoch = 0;           // 1970-01-01 00:00:00 UTC
time_t ontem = agora - 24 * 60 * 60; // 86400 segundos atrás
```

**Imprimindo um time_t**

Como o tamanho real depende da plataforma, não existe um especificador próprio no `printf`. A forma portável é converter para `long long` ou `intmax_t`:

```c
time_t agora = time(NULL);

printf("%lld\n", (long long)agora);
printf("%jd\n", (intmax_t)agora); // intmax_t vem de stdint.h
```

**Contas com time_t**

Por ser um número de segundos, somar e subtrair intervalos fixos é direto:

```c
time_t agora = time(NULL);

time_t daqui_uma_hora = agora + 60 * 60;
time_t semana_passada = agora - 7 * 24 * 60 * 60;

if (expira_em < agora) {
  // já expirou
}
```

> Somar `24 * 60 * 60` dá exatamente 24 horas depois, mas não necessariamente "o mesmo horário no dia seguinte": em lugares com horário de verão, um dia pode ter 23 ou 25 horas. Para somar dias, meses ou anos de calendário, o certo é usar a `struct tm` com o `mktime`

**O problema do ano 2038**

Em sistemas onde o `time_t` tem 32 bits com sinal, o maior valor possível é `2147483647`, que corresponde a `2038-01-19 03:14:07 UTC`. Um segundo depois, o número dá a volta e vira uma data em 1901. Sistemas de 64 bits não têm esse problema, mas ele ainda aparece em sistemas embarcados e em arquivos e protocolos que guardam o timestamp em 32 bits

```c
int32_t salvo = (int32_t)time(NULL); // vai quebrar em 2038
int64_t seguro = (int64_t)time(NULL);
```

> Diferente da `struct tm`, que separa a data em campos legíveis, o `time_t` é só um número, ideal para guardar, comparar e ordenar instantes. Para mostrar ao usuário, converte-se com `localtime` e `strftime`, e para diferenças use `difftime`, que funciona mesmo se o `time_t` não for um inteiro
