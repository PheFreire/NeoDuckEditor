**struct tm**

> `time.h`

A `struct tm` guarda uma data e hora separada em campos (ano, mês, dia, hora, minuto, segundo, dia da semana), sendo a forma usada para mostrar datas, ler partes delas e fazer contas de calendário como "somar um mês"

> Esse formato é chamado de "tempo quebrado" (broken-down time). Diferente do `time_t`, que é o mesmo número em qualquer lugar, uma `struct tm` representa a data como alguém em um fuso horário específico a veria: a mesma `time_t` vira uma `struct tm` diferente em UTC e no horário de Brasília

```c
struct tm {
  int tm_sec;   // segundos,          0 a 60 (60 para o segundo bissexto)
  int tm_min;   // minutos,           0 a 59
  int tm_hour;  // horas,             0 a 23
  int tm_mday;  // dia do mês,        1 a 31
  int tm_mon;   // mês,               0 a 11 (0 = janeiro)
  int tm_year;  // anos desde 1900    (2026 = 126)
  int tm_wday;  // dia da semana,     0 a 6 (0 = domingo)
  int tm_yday;  // dia do ano,        0 a 365 (0 = 1º de janeiro)
  int tm_isdst; // horário de verão:  > 0 sim, 0 não, < 0 desconhecido
};
```

- `tm_mon` começa em `0`, então janeiro é `0` e dezembro é `11`. Somar `1` para mostrar é obrigatório
- `tm_year` conta a partir de `1900`, então o ano real é `tm_year + 1900`
- `tm_mday` é o único campo de data que começa em `1`
- `tm_wday` e `tm_yday` são calculados pelas funções de conversão. Ao montar uma data à mão, eles são ignorados e preenchidos pelo `mktime`
- O Linux e o macOS ainda têm os campos extras `tm_gmtoff` (diferença para UTC em segundos) e `tm_zone` (nome do fuso, como `"-03"`), que não são padrão

---

**Lendo os campos**

```c
time_t agora = time(NULL);
struct tm *t = localtime(&agora);

printf("%02d/%02d/%04d %02d:%02d\n",
       t->tm_mday,
       t->tm_mon + 1,      // mês começa em 0
       t->tm_year + 1900,  // ano conta a partir de 1900
       t->tm_hour,
       t->tm_min);
// 04/10/2026 15:30

const char *dias[] = {"dom", "seg", "ter", "qua", "qui", "sex", "sab"};
printf("%s\n", dias[t->tm_wday]); // dom
```

---

**Montando uma data à mão**

Ao preencher uma `struct tm` para converter em `time_t`, é importante zerar a struct antes e deixar o `tm_isdst` em `-1`, para o `mktime` descobrir sozinho se há horário de verão:

```c
struct tm data = {0};
data.tm_year = 2026 - 1900;
data.tm_mon = 12 - 1;   // dezembro
data.tm_mday = 25;
data.tm_hour = 20;
data.tm_isdst = -1;

time_t natal = mktime(&data); // também preenche tm_wday e tm_yday
// data.tm_wday == 5, sexta-feira
```

> Esquecer o `- 1900` e o `- 1` é o erro mais comum com a `struct tm`: `tm_year = 2026` vira o ano 3926 e `tm_mon = 12` vira janeiro do ano seguinte, sem nenhum erro, pois o `mktime` aceita e corrige valores fora do intervalo

> Diferente do `time_t`, que é ótimo para comparar e guardar mas ilegível, a `struct tm` é ótima para mostrar e para mexer em partes da data, mas não deve ser comparada campo a campo. Para comparar ou ordenar datas, converta para `time_t` com `mktime`
