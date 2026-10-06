**gmtime**

> `time.h`

O `gmtime` converte um `time_t` em uma `struct tm` com a data e hora em UTC, o horário de referência mundial, sem nenhum fuso horário ou horário de verão aplicado, dando o mesmo resultado em qualquer máquina

> `UTC` (Tempo Universal Coordenado) é o horário de referência a partir do qual todos os fusos são definidos: o horário de Brasília é `UTC-3`, o de Tóquio é `UTC+9`. O nome da função vem de GMT (Greenwich Mean Time), o nome antigo do mesmo horário

```c
struct tm *gmtime(const time_t *t);
struct tm *gmtime_r(const time_t *t, struct tm *resultado); // POSIX, e C23
```

- `t`: ponteiro para o instante a ser convertido
- `resultado`: no `gmtime_r`, a struct que você já possui, onde o resultado vai ser escrito

- Devolve um ponteiro para a `struct tm` preenchida, ou `NULL` se a conversão falhar
- `tm_isdst` é sempre `0`, pois UTC não tem horário de verão
- Assim como o `localtime`, o `gmtime` devolve um ponteiro para uma struct estática compartilhada (inclusive com o próprio `localtime`), e o `gmtime_r` é a versão segura

```c
time_t epoch = 0;
struct tm utc;
gmtime_r(&epoch, &utc);

printf("%d-%02d-%02d %02d:%02d\n",
       utc.tm_year + 1900, utc.tm_mon + 1, utc.tm_mday,
       utc.tm_hour, utc.tm_min);
// 1970-01-01 00:00
```

**Data em formato ISO 8601**

O formato padrão para guardar e trocar datas entre sistemas, sempre em UTC e indicado pelo `Z` no final:

```c
time_t agora = time(NULL);
struct tm utc;
gmtime_r(&agora, &utc);

char iso[32];
strftime(iso, sizeof(iso), "%Y-%m-%dT%H:%M:%SZ", &utc);
printf("%s\n", iso); // 2026-10-04T18:00:00Z
```

**Diferença do fuso local para UTC**

Comparando o resultado do `localtime` com o do `gmtime` para o mesmo instante:

```c
time_t agora = time(NULL);
struct tm local, utc;
localtime_r(&agora, &local);
gmtime_r(&agora, &utc);

int diferenca = local.tm_hour - utc.tm_hour; // -3 em Brasília
// pode errar na virada do dia; no Linux e no macOS, local.tm_gmtoff dá o valor exato em segundos
```

**timegm: o caminho inverso**

O `mktime` converte uma `struct tm` em `time_t` interpretando-a como horário local. Para interpretar como UTC, existe o `timegm`, que não fazia parte do padrão até o C23, mas já existia no Linux e no macOS:

```c
struct tm utc = {0};
utc.tm_year = 2026 - 1900;
utc.tm_mon = 0;
utc.tm_mday = 1;

time_t t = timegm(&utc); // 1767225600, independente do fuso da máquina
```

> Diferente do `localtime`, que depende do fuso configurado e pode mudar com o horário de verão, o `gmtime` é sempre igual em qualquer lugar. Por isso datas em logs, bancos de dados e APIs devem ser guardadas em UTC, e só convertidas para o horário local na hora de mostrar ao usuário
