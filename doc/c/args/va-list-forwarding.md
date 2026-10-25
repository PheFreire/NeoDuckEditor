**Repassando um va_list**

> `stdarg.h` e `stdio.h`

Uma função variádica não consegue repassar o seu `...` direto para outra função variádica. O que ela consegue é transformar os argumentos em um `va_list` com o `va_start` e entregá-lo para uma função que aceite um `va_list`. Por isso a família do `printf` tem versões com `v` na frente do nome, que recebem um `va_list` no lugar do `...`

| com `...` | com `va_list` | escreve em |
|---|---|---|
| `printf` | `vprintf` | `stdout` |
| `fprintf` | `vfprintf` | um `FILE *` |
| `sprintf` | `vsprintf` | um buffer, sem limite |
| `snprintf` | `vsnprintf` | um buffer, com limite |
| `scanf` | `vscanf` | lê do `stdin` |

```c
#include <stdarg.h>
#include <stdio.h>

void logar(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  fprintf(stderr, "[log] ");
  vfprintf(stderr, fmt, args);   // usa os argumentos que vieram no ...
  fprintf(stderr, "\n");
  va_end(args);
}

logar("porta %d", 8080);   // [log] porta 8080
```

- A função `v*` lê os valores do `va_list`, mas não chama `va_end`. Isso continua sendo responsabilidade de quem chamou o `va_start`
- Chamar `fprintf(stderr, fmt, args)` em vez de `vfprintf` compila, mas passa o `va_list` como se fosse um único valor, e imprime lixo

---

**Exemplo prático: log colorido com vsnprintf**

Uma função de log que recebe uma mensagem com formato, monta o texto em um buffer com `vsnprintf` e depois imprime esse texto em verde, junto com uma linha separadora:

```c
#include <stdarg.h>
#include <stdio.h>

#define DEBUG 1   // 0 desliga todos os logs
#define LINE "----------------------------------------\n"

void log_green(const char *msg, ...) {
  if (!DEBUG) return;
  
  char buffer[256];
  va_list argptr;
  va_start(argptr, msg);
  vsnprintf(buffer, sizeof buffer, msg, argptr);
  va_end(argptr);

  printf("\033[32m[LOG] %s\033[0m\n%s", buffer, LINE);
}

int main(void) {
  log_green("servidor iniciado na porta %d", 8080);
  log_green("cliente %s conectado", "127.0.0.1");
  return 0;
}
```

```text
[LOG] servidor iniciado na porta 8080      (em verde no terminal)
----------------------------------------
[LOG] cliente 127.0.0.1 conectado          (em verde no terminal)
----------------------------------------
```

- `const char *msg, ...`: a mensagem é a string de formato, e os valores vêm no `...`, como no `printf`. Não precisa de `count`, pois cada `%d` e `%s` de `msg` diz quantos valores existem e de que tipo
- `if (!DEBUG) return`: com `DEBUG` em `0`, a função sai antes de formatar qualquer coisa. Como `DEBUG` é uma constante, o compilador remove o resto da função no build com otimização
- `vsnprintf(buffer, sizeof buffer, msg, argptr)`: formata a mensagem com os argumentos do `...` dentro do `buffer`, escrevendo no máximo 255 caracteres mais o `\0`. Uma mensagem maior é cortada, sem nunca passar do fim do buffer
- `sizeof buffer`: o tamanho do array (`256`), calculado na compilação. Só funciona porque `buffer` é um array local, e não um ponteiro
- `va_end(argptr)`: pode ser chamado logo depois do `vsnprintf`, pois o texto já está pronto no `buffer` e os argumentos não são mais necessários
- O `printf` final usa `%s` para o `buffer`, e não o `buffer` como formato. Um `printf(buffer)` interpretaria de novo qualquer `%` que veio dentro da mensagem formatada

Formatar primeiro no buffer, em vez de chamar `vprintf` direto, permite tratar a mensagem pronta como uma string comum: colocar a cor e o `[LOG]` em volta dela, medir o tamanho ou gravar o mesmo texto em um arquivo além do terminal

Como a função não tem o atributo `format`, uma chamada com o tipo errado compila sem nenhum aviso:

```c
log_green("porta %d", "8080");   // [LOG] porta 37027737
```

Declarando a função com o atributo, o compilador passa a avisar (abaixo):

```c
__attribute__((format(printf, 1, 2)))
void log_green(const char *msg, ...);
// warning: format specifies type 'int' but the argument has type 'char *' [-Wformat]
```

---

**Verificando o formato: atributo format**

Em uma chamada direta de `printf`, o compilador confere se cada `%d` recebe um `int` e cada `%s` recebe uma string. Em uma função própria, essa verificação se perde, a não ser que ela seja marcada com o atributo `format`:

```c
__attribute__((format(printf, 1, 2)))
void logar(const char *fmt, ...);

logar("porta %d", "8080");
// warning: format specifies type 'int' but the argument has type 'char *' [-Wformat]
```

- `format(printf, 1, 2)`: o parâmetro 1 é a string de formato, e os valores começam no parâmetro 2
- É uma extensão do GCC e do Clang, mas deveria acompanhar toda função que repassa um formato para a família `v*printf`

---

**Usando o va_list duas vezes**

Depois que uma função `v*` usa o `va_list`, ele não pode ser lido de novo. Para medir um texto e depois escrevê-lo, faça uma cópia antes com `va_copy` (ver `stdarg.md`):

```c
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

char *formatar(const char *fmt, ...) {
  va_list args, copia;
  va_start(args, fmt);
  va_copy(copia, args);

  int len = vsnprintf(NULL, 0, fmt, args);   // só mede
  va_end(args);

  char *str = len < 0 ? NULL : malloc((size_t)len + 1);
  if (str != NULL) {
    vsnprintf(str, (size_t)len + 1, fmt, copia);  // escreve
  }
  va_end(copia);
  return str;
}

char *s = formatar("%s-%d", "item", 1024);  // "item-1024"
free(s);
```

> Ao escrever uma função com `...` que monta texto, comece sempre pela versão `v*` correspondente (`vfprintf` para log, `vsnprintf` para buffers). Ver também `string/casting/vsprintf.md` em `doc/c`, com o `vsprintf` e o `vsnprintf` em detalhe
