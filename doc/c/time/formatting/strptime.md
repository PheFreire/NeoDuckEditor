**strptime**

> `time.h` (POSIX)

O `strptime` faz o caminho inverso do `strftime`: lê um texto com uma data e hora, de acordo com um formato com os mesmos especificadores (`%d`, `%m`, `%Y`), e preenche os campos de uma `struct tm`

> O nome vem de "string parse time". Ele funciona como um `sscanf` especializado em datas: cada especificador do formato consome uma parte do texto e guarda o valor no campo certo da struct, já fazendo as correções como `- 1900` no ano e `- 1` no mês

```c
char *strptime(const char *str, const char *format, struct tm *t);
```

- `str`: o texto com a data a ser lida
- `format`: o formato esperado, com os mesmos especificadores do `strftime`
- `t`: a struct onde os campos lidos vão ser guardados

- Devolve um ponteiro para o primeiro caractere de `str` que não foi lido, ou `NULL` se o texto não corresponder ao formato
- Preenche apenas os campos que aparecem no formato. Os outros ficam como estavam, por isso a struct deve ser zerada antes
- Não preenche o `tm_isdst`, que deve ser colocado em `-1` antes de passar a struct para o `mktime`
- Faz parte do POSIX e não do padrão C: funciona no Linux e no macOS, mas não no Windows. No glibc, pode ser preciso definir `_XOPEN_SOURCE` antes do `#include`

```c
#define _XOPEN_SOURCE 700 // necessário no glibc com -std=c99/c11
#include <time.h>

struct tm t = {0};

if (strptime("25/12/2026 20:30", "%d/%m/%Y %H:%M", &t) == NULL) {
  // o texto não está no formato esperado
}

// t.tm_mday == 25, t.tm_mon == 11, t.tm_year == 126
// t.tm_hour == 20, t.tm_min == 30
```

**Convertendo texto em time_t**

```c
time_t texto_para_time(const char *texto) {
  struct tm t = {0};

  if (strptime(texto, "%Y-%m-%d %H:%M:%S", &t) == NULL) {
    return (time_t)-1;
  }

  t.tm_isdst = -1;
  return mktime(&t);
}

time_t natal = texto_para_time("2026-12-25 20:00:00");
```

**Exigindo que o texto inteiro seja lido**

Como o retorno aponta para o que sobrou, é possível rejeitar textos com lixo depois da data:

```c
const char *entrada = "2026-10-04abc";
struct tm t = {0};

char *resto = strptime(entrada, "%Y-%m-%d", &t);
if (resto == NULL || *resto != '\0') {
  // inválido: formato errado ou sobrou texto ("abc")
}
```

**Convertendo entre formatos**

Lendo com o `strptime` e escrevendo com o `strftime`:

```c
struct tm t = {0};
strptime("04/10/2026", "%d/%m/%Y", &t);

char iso[16];
strftime(iso, sizeof(iso), "%Y-%m-%d", &t);
// iso == "2026-10-04"
```

> O `strptime` aceita algumas datas inválidas que correspondem ao formato, como `31/02/2026`. Para validar de verdade, passe a struct pelo `mktime` e confira se os campos continuam iguais, como mostrado em `conversion/mktime.md`

> Diferente do `sscanf` com `"%d/%d/%d"`, que só lê números e exige as contas de `- 1900` e `- 1` à mão, o `strptime` entende os mesmos formatos do `strftime`, inclusive nomes de meses (`%b`). Em código que precisa rodar no Windows, onde ele não existe, o `sscanf` seguido do preenchimento manual da `struct tm` é a alternativa
