**strtol**

> `stdlib.h`

O `strtol` também converte uma string em um número inteiro, mas de forma mais robusta que `atoi`, permitindo escolher a base numérica, detectar overflow e saber exatamente até onde a conversão avançou na string

```c
#include <stdlib.h>

long strtol(const char *str, char **endptr, int base);
```

- `str`: a string a ser convertida para inteiro
- `endptr`: ponteiro para um `char *` que vai receber o endereço do primeiro caractere não convertido em `str`, logo após o número lido; pode ser `NULL` se essa informação não for necessária
- `base`: a base numérica usada na conversão (por exemplo `10` para decimal, `16` para hexadecimal); `0` faz a função deduzir a base pelo prefixo da string (`0x`/`0X` para hexadecimal, `0` para octal, decimal caso contrário)

- Retorna o valor convertido como `long`; se nenhum número puder ser reconhecido, retorna `0` e, se `endptr` não for `NULL`, ele é preenchido apontando para o início de `str`, permitindo distinguir esse caso de uma conversão bem-sucedida do número `0`
- Se o número representado for grande demais para caber em um `long`, retorna `LONG_MAX` ou `LONG_MIN` (dependendo do sinal) e ajusta a variável global `errno` para `ERANGE`, ao contrário de `atoi`, que tem comportamento indefinido nesse mesmo caso
- Assim como `atoi`, ignora espaços em branco no início da string e aceita um sinal opcional (`+` ou `-`) antes dos dígitos
- Ler o valor apontado por `endptr` depois da chamada é a forma recomendada de checar se a conversão de fato encontrou algum número, já que `str` inteiro sendo consumido significa que `endptr` aponta para o `'\0'` no final da string

```c
char *fim;
long n1 = strtol("42", &fim, 10);       // 42, fim aponta para '\0'
long n2 = strtol("  -17abc", &fim, 10); // -17, fim aponta para "abc"
long n3 = strtol("abc", &fim, 10);      // 0, fim aponta para o início de "abc"
long n4 = strtol("ff", &fim, 16);       // 255
```

