**difftime**

> `time.h`

O `difftime` calcula a diferença em segundos entre dois instantes do tipo `time_t`, devolvendo o resultado como `double`, sendo a forma portável de saber quanto tempo se passou entre duas datas

> O padrão C não garante que o `time_t` seja um inteiro contando segundos. Em teoria, ele poderia usar outra unidade ou representação. O `difftime` esconde esse detalhe e sempre devolve a diferença em segundos, enquanto `fim - inicio` só funciona porque, na prática, todo sistema atual usa segundos

```c
double difftime(time_t fim, time_t inicio);
```

- `fim`: o instante mais recente
- `inicio`: o instante mais antigo

- Devolve `fim - inicio` em segundos, como `double`
- Se `inicio` for depois de `fim`, o resultado é negativo
- A precisão é de segundos, a mesma do `time_t`

```c
time_t inicio = time(NULL);
// ... algum processamento demorado
time_t fim = time(NULL);

double segundos = difftime(fim, inicio);
printf("levou %.0f segundos\n", segundos);
```

**Dias entre duas datas**

Combinando com o `mktime` para montar as datas:

```c
struct tm a = {0};
a.tm_year = 2026 - 1900;
a.tm_mon = 0;   // janeiro
a.tm_mday = 1;
a.tm_hour = 12;
a.tm_isdst = -1;

struct tm b = {0};
b.tm_year = 2026 - 1900;
b.tm_mon = 11;  // dezembro
b.tm_mday = 25;
b.tm_hour = 12;
b.tm_isdst = -1;

double dias = difftime(mktime(&b), mktime(&a)) / (24 * 60 * 60);
printf("%.0f dias\n", dias); // 358 dias
```

> Usar o meio-dia (`tm_hour = 12`) em vez da meia-noite evita que uma mudança de horário de verão entre as duas datas faça a divisão dar `357.958` em vez de `358`. Arredondar com `round` também resolve

**Idade de uma pessoa em anos (aproximada)**

```c
double segundos = difftime(time(NULL), nascimento);
double anos = segundos / (365.25 * 24 * 60 * 60);
```

> A conta acima é uma aproximação. Para a idade exata em anos de calendário, compare os campos `tm_year`, `tm_mon` e `tm_mday` das duas `struct tm`

> Diferente de subtrair dois `timespec` do `clock_gettime`, que dá precisão de nanossegundos, o `difftime` trabalha só com segundos inteiros. Ele é a escolha certa para diferenças entre datas (dias, horas, idade), e o `clock_gettime(CLOCK_MONOTONIC)` para medir a duração de um trecho de código
