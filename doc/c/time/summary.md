**time.h**

> `time.h`

A `time.h` é a biblioteca de data e hora do C, com funções para obter o momento atual, medir quanto tempo algo levou, converter um instante em dia, mês, ano e hora, fazer contas com datas e formatar o resultado como texto

> O C representa o tempo de duas formas. A primeira é um número (`time_t`), que conta os segundos desde um instante fixo, bom para guardar e fazer contas. A segunda é uma struct (`struct tm`), com campos separados para ano, mês, dia, hora, minuto e segundo, boa para mostrar e para mexer em partes da data. Boa parte da biblioteca é converter de uma forma para a outra

```c
#include <time.h>
```

- No Linux e no macOS, a `time.h` não precisa de nenhuma flag extra de compilação (em versões muito antigas do glibc, o `clock_gettime` precisava de `-lrt`)
- Algumas funções muito usadas (`clock_gettime`, `nanosleep`, `localtime_r`, `strptime`) vêm do POSIX e não do padrão C: funcionam no Linux e no macOS, mas não no Windows sem adaptações

---

**Os três tipos de tempo**

- **Tempo de calendário** (wall clock): a data e hora do mundo real, como `2026-10-04 15:30:00`. Obtido com `time` ou `clock_gettime(CLOCK_REALTIME)`, e pode "pular" se o relógio do sistema for ajustado
- **Tempo monotônico**: um contador que só anda para frente, sem relação com a data. Obtido com `clock_gettime(CLOCK_MONOTONIC)`, é o certo para medir quanto tempo algo demorou
- **Tempo de processador** (CPU): quanto tempo o processador gastou executando o seu programa. Obtido com `clock`, não conta o tempo em que o programa ficou parado esperando

---

**O caminho entre os tipos**

```c
//                 localtime / gmtime               strftime
//   time_t  ──────────────────────────►  struct tm  ─────────►  "04/10/2026 15:30"
//   (número) ◄──────────────────────────  (campos)  ◄─────────  (texto)
//                 mktime / timegm                   strptime
```

---

**Fusos horários**

- `gmtime` converte para UTC, o horário de referência mundial, igual em qualquer lugar
- `localtime` converte para o fuso horário configurado na máquina (variável de ambiente `TZ`, ou `/etc/localtime`)
- O `time_t` em si não tem fuso: é o mesmo número em qualquer lugar do mundo no mesmo instante

```sh
TZ=UTC ./programa                # roda o programa como se estivesse em UTC
TZ=America/Sao_Paulo ./programa  # roda no horário de Brasília
```

Docs deste diretório:

- `types/`: `time_t`, `struct tm`, `struct timespec`
- `current/`: `time`, `clock_gettime`, `timespec_get`
- `measure/`: `clock`, `difftime`
- `conversion/`: `localtime`, `gmtime`, `mktime`
- `formatting/`: `strftime`, `strptime`, `ctime` / `asctime`
- `sleep/`: `sleep`, `nanosleep`

> Diferente de linguagens com uma biblioteca de datas completa, a `time.h` não tem funções prontas para "somar 3 dias" ou "diferença em meses". Essas contas são feitas mexendo nos campos da `struct tm` e deixando o `mktime` corrigir o resultado, como mostrado em `conversion/mktime.md`
