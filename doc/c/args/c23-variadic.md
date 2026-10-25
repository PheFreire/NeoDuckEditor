**Funções variádicas no C23**

> `stdarg.h`, a partir do C23

Até o C17, uma função variádica precisa de pelo menos um parâmetro fixo antes do `...`, porque o `va_start` usa esse parâmetro para saber onde os argumentos extras começam. O C23 tirou essa exigência: uma função pode ter só o `...`, e o `va_start` passou a receber apenas o `va_list`

```c
#include <stdarg.h>

int primeiro(...) {
  va_list args;
  va_start(args);          // C23: sem o segundo argumento
  int x = va_arg(args, int);
  va_end(args);
  return x;
}

primeiro(3);  // 3
```

- `-std=c23` no GCC 14+ e no Clang 18+, ou `-std=c2x` em versões anteriores
- Antes do C23, a mesma função é erro de compilação: `ISO C requires a named parameter before '...'`
- No C23 o `va_start` ainda aceita o segundo argumento por compatibilidade, mas ele é ignorado

---

**Para que serve**

- Sem um parâmetro fixo, a função continua sem saber quantos argumentos vieram. A informação precisa vir de um sentinela ou de algum estado externo (ver `variadic-functions.md`)
- O uso principal é declarar funções que recebem qualquer coisa, como um callback genérico, e a compatibilidade com o C++, que sempre permitiu `void f(...)`

> No C23 também mudou o significado de `()`: `int f()` passou a ser igual a `int f(void)`, uma função **sem** argumentos. Antes, `()` queria dizer "argumentos não especificados", o que permitia chamar a função com qualquer coisa sem nenhuma verificação. Para uma função que aceita uma quantidade variável de argumentos, o jeito certo sempre foi o `...`
