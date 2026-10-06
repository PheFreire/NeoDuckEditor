**mktime**

> `time.h`

O `mktime` converte uma `struct tm` com uma data e hora locais em um `time_t`, e no caminho corrige os campos fora do intervalo (como dia 32 ou mês 13) e preenche o dia da semana e o dia do ano, sendo a base para fazer contas com datas em C

> Corrigir campos fora do intervalo é chamado de `normalização`: o dia `32` de janeiro vira `1` de fevereiro, a hora `25` vira `1` hora do dia seguinte, o dia `0` vira o último dia do mês anterior. É isso que permite "somar 10 dias" simplesmente fazendo `tm_mday += 10`

```c
time_t mktime(struct tm *t);
```

- `t`: a data a ser convertida, interpretada como horário local. A struct é modificada pela função

- Devolve o instante correspondente como `time_t`, ou `(time_t)-1` se a data não puder ser representada
- Ignora os valores de `tm_wday` e `tm_yday` na entrada, e os preenche corretamente na saída
- Normaliza todos os campos: depois da chamada, cada um está de volta no seu intervalo válido
- `tm_isdst` indica se a data está em horário de verão: `0` (não), positivo (sim) ou `-1` (deixar o `mktime` descobrir), que é quase sempre o que se quer

```c
struct tm data = {0};
data.tm_year = 2026 - 1900;
data.tm_mon = 9;    // outubro
data.tm_mday = 4;
data.tm_hour = 15;
data.tm_isdst = -1;

time_t t = mktime(&data);
// data.tm_wday == 0 (domingo), data.tm_yday == 276
```

**Somando dias, meses e anos**

Basta mexer no campo desejado e chamar o `mktime`, que acerta a virada de mês, de ano e os anos bissextos:

```c
struct tm data = {0};
data.tm_year = 2026 - 1900;
data.tm_mon = 11;   // dezembro
data.tm_mday = 25;
data.tm_isdst = -1;

data.tm_mday += 10;
mktime(&data);
// 4 de janeiro de 2027
```

```c
data.tm_mon += 1;   // um mês depois
data.tm_year += 1;  // um ano depois
data.tm_mday -= 30; // 30 dias antes
mktime(&data);
```

> Somar um mês a `31 de janeiro` dá `31 de fevereiro`, que o `mktime` normaliza para `3 de março` (ou `2`, em ano bissexto). Se o resultado precisa ser "o último dia de fevereiro", é preciso tratar esse caso à mão

**Último dia do mês**

O dia `0` de um mês é o último dia do mês anterior:

```c
struct tm data = {0};
data.tm_year = 2028 - 1900;
data.tm_mon = 2;   // março
data.tm_mday = 0;  // dia 0 de março = último dia de fevereiro
data.tm_isdst = -1;

mktime(&data);
// data.tm_mday == 29, 2028 é bissexto
```

**Dia da semana de uma data**

```c
struct tm data = {0};
data.tm_year = 2000 - 1900;
data.tm_mon = 0;
data.tm_mday = 1;
data.tm_hour = 12;
data.tm_isdst = -1;

mktime(&data);

const char *dias[] = {"domingo", "segunda", "terça", "quarta", "quinta", "sexta", "sábado"};
printf("%s\n", dias[data.tm_wday]); // sábado
```

**Validando uma data digitada**

Se a data mudar depois do `mktime`, é porque algum campo estava fora do intervalo:

```c
int data_valida(int dia, int mes, int ano) {
  struct tm t = {0};
  t.tm_year = ano - 1900;
  t.tm_mon = mes - 1;
  t.tm_mday = dia;
  t.tm_hour = 12;
  t.tm_isdst = -1;

  mktime(&t);
  return t.tm_mday == dia && t.tm_mon == mes - 1 && t.tm_year == ano - 1900;
}

data_valida(29, 2, 2026); // 0, 2026 não é bissexto (virou 1º de março)
data_valida(29, 2, 2028); // 1
```

> Diferente do `timegm`, que interpreta a `struct tm` como UTC, o `mktime` sempre usa o fuso local, então o mesmo `struct tm` gera `time_t` diferentes em máquinas com fusos diferentes. É o inverso exato do `localtime`, assim como o `timegm` é o inverso do `gmtime`
