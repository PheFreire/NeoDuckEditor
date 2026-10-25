**vsprintf**

> `stdio.h`

O `vsprintf` escreve texto formatado dentro de uma string, igual ao `sprintf`, mas recebe os valores em um `va_list` em vez de recebê-los direto na chamada. Existe para ser usado dentro de uma função variádica própria, que recebe um formato e os seus `...` e precisa repassá-los para a formatação

> Uma função variádica (como `void f(const char *fmt, ...)`) não consegue repassar o seu `...` para outra função. O que ela consegue é transformar esses argumentos em um `va_list` com o `va_start` e entregá-lo para uma função que aceite um `va_list`. Por isso cada função da família do `printf` tem uma versão com `v` na frente do nome: `vprintf`, `vfprintf`, `vsprintf` e `vsnprintf` (ver `args/variadic-functions.md` em `doc/c`)

```c
#include <stdarg.h>
#include <stdio.h>

int vsprintf(char *str, const char *format, va_list ap);
```

- `str`: o buffer que você já possui, para onde o texto formatado vai ser escrito. Precisa ter espaço para o texto inteiro mais o `\0`
- `format`: a string de formato, com os mesmos especificadores do `printf` (`%d`, `%f`, `%s`, `%x`, etc)
- `ap`: o `va_list` com os valores, já inicializado com `va_start` pela função que chamou

- Devolve a quantidade de caracteres escritos, sem contar o `\0`. Devolve um valor negativo se ocorrer erro de formatação
- Sempre adiciona o `\0` no final do texto escrito
- Assim como o `sprintf`, não recebe o tamanho do buffer e pode causar um **buffer overflow** se o texto não couber
- Lê os valores do `ap`, que fica em um estado indefinido depois da chamada: não pode ser usado de novo sem um novo `va_start` ou uma cópia feita antes com `va_copy`
- Não chama `va_end`. Isso continua sendo responsabilidade de quem chamou o `va_start`

```c
#include <stdarg.h>
#include <stdio.h>

int formatar(char *buf, const char *format, ...) {
  va_list args;
  va_start(args, format);              // transforma o ... em um va_list
  int n = vsprintf(buf, format, args); // entrega o va_list para a formatação
  va_end(args);
  return n;
}

char buf[64];
formatar(buf, "id=%d nome=%s", 7, "ana"); // "id=7 nome=ana", devolve 13
```

---

**vsnprintf: a versão com limite**

```c
int vsnprintf(char *str, size_t size, const char *format, va_list ap);
```

- É o `snprintf` com `va_list`: escreve no máximo `size - 1` caracteres mais o `\0`, e devolve o tamanho que o texto completo teria (ver `snprintf.md`)
- Tem o mesmo motivo para ser preferido ao `vsprintf` que o `snprintf` tem em relação ao `sprintf`: nunca escreve além do buffer

```c
int formatar_seguro(char *buf, size_t size, const char *format, ...) {
  va_list args;
  va_start(args, format);
  int n = vsnprintf(buf, size, format, args);
  va_end(args);
  return n;
}

char p[8];
formatar_seguro(p, sizeof(p), "%d", 123456789); // p == "1234567", devolve 9 (não coube)
```

Alocando exatamente o espaço necessário, que precisa do `va_list` duas vezes (uma para medir e outra para escrever):

```c
char *formatar_alocado(const char *format, ...) {
  va_list args, copia;
  va_start(args, format);
  va_copy(copia, args);                        // cópia antes do primeiro uso

  int len = vsnprintf(NULL, 0, format, args);  // só mede, consome args
  va_end(args);
  if (len < 0) {
    va_end(copia);
    return NULL;
  }

  char *str = malloc((size_t)len + 1);         // + 1 para o '\0'
  if (str != NULL) {
    vsnprintf(str, (size_t)len + 1, format, copia);
  }
  va_end(copia);
  return str;
}

char *s = formatar_alocado("%s-%d", "item", 1024); // "item-1024"
free(s);
```

- Sem o `va_copy`, o segundo `vsnprintf` leria um `va_list` já consumido, o que é comportamento indefinido

---

**Verificando o formato na compilação**

Em uma chamada direta de `sprintf`, o compilador confere se cada `%d` recebe um `int` e cada `%s` recebe uma string. Em uma função própria que repassa para o `vsprintf`, essa verificação se perde, a não ser que a função seja marcada com o atributo `format`:

```c
__attribute__((format(printf, 2, 3)))
int formatar(char *buf, const char *format, ...);

formatar(buf, "porta %d", "8080");
// warning: format specifies type 'int' but the argument has type 'char *' [-Wformat]
```

- `format(printf, 2, 3)`: o parâmetro 2 é a string de formato, e os valores começam no parâmetro 3
- É uma extensão do GCC e do Clang, mas tão comum que deveria acompanhar toda função que repassa um formato para a família `v*printf`

> Use o `vsprintf` e o `vsnprintf` só quando estiver escrevendo a sua própria função com `...`, como uma função de log ou de mensagens de erro. Para formatar uma string diretamente, o `snprintf` faz o mesmo trabalho sem precisar de `va_list`. E, entre os dois, prefira sempre o `vsnprintf`, pela mesma razão de preferir o `snprintf` ao `sprintf`: o buffer nunca é ultrapassado
