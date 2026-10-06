**strtol**

> `stdlib.h`

O `strtol` converte uma string em um número inteiro de forma mais robusta que o `atoi`, permitindo escolher a base numérica, detectar overflow e saber exatamente até onde a conversão avançou na string

```c
long strtol(const char *str, char **endptr, int base);
```

- `str`: a string a ser convertida para inteiro
- `endptr`: ponteiro para um `char *` que vai receber o endereço do primeiro caractere não convertido em `str`, logo após o número lido. Pode ser `NULL` se essa informação não for necessária
- `base`: a base numérica usada na conversão (por exemplo `10` para decimal, `16` para hexadecimal). `0` faz a função deduzir a base pelo prefixo da string (`0x`/`0X` para hexadecimal, `0` para octal, decimal caso contrário)

- Devolve o valor convertido como `long`. Se nenhum número puder ser reconhecido, devolve `0` e faz `endptr` apontar para o início de `str`, permitindo distinguir esse caso de uma conversão bem-sucedida do número `0`
- Se o número for grande demais para caber em um `long`, devolve `LONG_MAX` ou `LONG_MIN` (dependendo do sinal) e ajusta a variável global `errno` para `ERANGE`
- Assim como o `atoi`, ignora espaços em branco no início da string e aceita um sinal opcional (`+` ou `-`) antes dos dígitos
- Se a string inteira foi consumida, `endptr` aponta para o `\0` final, o que permite checar se o texto era composto apenas pelo número

```c
char *fim;
long n1 = strtol("42", &fim, 10);       // 42, fim aponta para '\0'
long n2 = strtol("  -17abc", &fim, 10); // -17, fim aponta para "abc"
long n3 = strtol("abc", &fim, 10);      // 0, fim aponta para o início de "abc"
long n4 = strtol("ff", &fim, 16);       // 255
```

> Diferente do `atoi`, que tem comportamento indefinido quando o número não cabe no tipo e não diferencia `"0"` de um texto inválido, o `strtol` sinaliza os dois casos, sendo a forma recomendada de converter entradas vindas do usuário ou de arquivos
