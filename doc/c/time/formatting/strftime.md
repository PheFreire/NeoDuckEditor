**strftime**

> `time.h`

O `strftime` transforma uma `struct tm` em texto, de acordo com um formato com especificadores como `%d`, `%m` e `%Y`, funcionando como um `printf` próprio para datas e horas e escrevendo o resultado em um buffer que você já possui

> Cada especificador começa com `%` e é trocado por uma parte da data, já com os zeros à esquerda e as correções necessárias: `%m` já soma `1` ao `tm_mon`, e `%Y` já soma `1900` ao `tm_year`, evitando as contas que seriam necessárias com o `printf`

```c
size_t strftime(char *str, size_t max, const char *format, const struct tm *t);
```

- `str`: o buffer que você já possui, onde o texto vai ser escrito
- `max`: o tamanho total do buffer, incluindo o espaço para o `\0`
- `format`: o formato, misturando texto comum e especificadores
- `t`: a data a ser formatada, normalmente vinda do `localtime` ou do `gmtime`

- Devolve a quantidade de caracteres escritos, sem contar o `\0`
- Se o resultado não couber em `max`, devolve `0` e o conteúdo de `str` fica indefinido
- Nunca escreve além de `max`, então é seguro contra buffer overflow

```c
time_t agora = time(NULL);
struct tm local;
localtime_r(&agora, &local);

char texto[64];
strftime(texto, sizeof(texto), "%d/%m/%Y %H:%M:%S", &local);
printf("%s\n", texto); // 04/10/2026 15:00:00
```

---

**Especificadores mais usados**

Data:
- `%Y`: ano com 4 dígitos (`2026`)
- `%y`: ano com 2 dígitos (`26`)
- `%m`: mês com 2 dígitos (`10`)
- `%d`: dia do mês com 2 dígitos (`04`)
- `%e`: dia do mês com espaço à esquerda em vez de zero (` 4`)
- `%j`: dia do ano, de `001` a `366`
- `%F`: atalho para `%Y-%m-%d` (`2026-10-04`)

Hora:
- `%H`: hora de `00` a `23`
- `%I`: hora de `01` a `12`
- `%p`: `AM` ou `PM`
- `%M`: minutos (`00` a `59`)
- `%S`: segundos (`00` a `60`)
- `%T`: atalho para `%H:%M:%S` (`15:00:00`)

Nomes (dependem do locale, em inglês por padrão):
- `%a` / `%A`: dia da semana abreviado / completo (`Sun` / `Sunday`)
- `%b` / `%B`: mês abreviado / completo (`Oct` / `October`)

Fuso e outros:
- `%z`: diferença para UTC (`-0300`)
- `%Z`: nome ou abreviação do fuso (`-03`, `UTC`, `BRT`)
- `%u`: dia da semana de `1` (segunda) a `7` (domingo)
- `%w`: dia da semana de `0` (domingo) a `6`
- `%%`: o caractere `%`

---

**Formatos comuns**

```c
strftime(s, n, "%Y-%m-%d", &t);           // 2026-10-04
strftime(s, n, "%d/%m/%Y", &t);           // 04/10/2026
strftime(s, n, "%H:%M", &t);              // 15:00
strftime(s, n, "%Y-%m-%dT%H:%M:%S%z", &t); // 2026-10-04T15:00:00-0300 (ISO 8601)
strftime(s, n, "%a, %d %b %Y", &t);       // Sun, 04 Oct 2026
strftime(s, n, "%Y%m%d_%H%M%S", &t);      // 20261004_150000
```

---

**Nome de arquivo com data**

O formato `%Y%m%d_%H%M%S` não tem caracteres proibidos em nomes de arquivo e ordena alfabeticamente na mesma ordem cronológica:

```c
char nome[64];
strftime(nome, sizeof(nome), "backup_%Y%m%d_%H%M%S.tar", &local);
// backup_20261004_150000.tar
```

---

**Nomes em português**

Os nomes de dias e meses seguem o locale do programa, que por padrão é o `"C"` (inglês). Com o `setlocale`, de `locale.h`, eles passam a seguir o idioma configurado, se ele estiver instalado no sistema:

```c
#include <locale.h>

setlocale(LC_TIME, "pt_BR.UTF-8");
strftime(texto, sizeof(texto), "%A, %d de %B de %Y", &local);
// domingo, 04 de outubro de 2026 (no macOS: Domingo, 04 de Outubro de 2026)
```

> Diferente de montar a data com `printf` e os campos da `struct tm`, onde é fácil esquecer o `+ 1` do mês ou o `+ 1900` do ano, o `strftime` faz essas correções sozinho. Além disso, diferente do `ctime`, que tem um formato fixo em inglês, ele permite qualquer formato. O caminho inverso, de texto para `struct tm`, é feito pelo `strptime`
