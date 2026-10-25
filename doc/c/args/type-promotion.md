**Promoção dos argumentos variádicos**

> regra da linguagem, aplicada aos argumentos do `...`

Os argumentos que caem no `...` não chegam com o tipo que tinham na chamada. Como a função não tem um protótipo dizendo o tipo deles, o C aplica as `default argument promotions` antes de enviá-los: os tipos pequenos são convertidos para tipos maiores, e o `va_arg` precisa ler o tipo convertido

- `char`, `signed char`, `unsigned char`, `short` e `unsigned short` viram `int`
- `float` vira `double`
- `bool` vira `int`
- Os outros tipos (`int`, `long`, `double`, ponteiros, structs) chegam como estão

---

**Lendo o tipo certo**

```c
float f = va_arg(args, float);       // errado: o valor chegou como double
double d = va_arg(args, double);     // certo
float f2 = (float)va_arg(args, double);  // certo, convertendo depois

char c = va_arg(args, char);         // errado: o valor chegou como int
char c2 = (char)va_arg(args, int);   // certo
```

```text
warning: second argument to 'va_arg' is of promotable type 'float'; this va_arg has undefined behavior because arguments will be promoted to 'double' [-Wvarargs]
warning: second argument to 'va_arg' is of promotable type 'char'; this va_arg has undefined behavior because arguments will be promoted to 'int' [-Wvarargs]
```

- O compilador avisa nesses casos, e o resultado é comportamento indefinido
- É por isso que o `printf` usa o mesmo `%f` para `float` e para `double`, e o mesmo `%d` para `char`, `short` e `int`: ele sempre recebe um `double` ou um `int`

---

**O tipo de quem chama também importa**

A promoção só aumenta tipos pequenos. Ela não converte um `int` em `double` nem o contrário, então o valor passado precisa ser do tipo que a função lê:

```c
double media(int n, ...) {
  va_list args;
  va_start(args, n);
  double soma = 0;
  for (int i = 0; i < n; i++) {
    soma += va_arg(args, double);
  }
  va_end(args);
  return soma / n;
}

media(3, 1.0, 2.0, 4.5);   // 2.50
media(2, 1, 2);            // 0.00: 1 e 2 são int, e a função os lê como double
```

- Em uma função normal, `media(2, 1, 2)` converteria os `int` para `double` pelo protótipo. No `...` isso não acontece
- O mesmo vale para `0` passado como sentinela no lugar de um ponteiro: ele é um `int`, e pode ter tamanho diferente de um ponteiro. Use `NULL` ou `(char *)0`

> Na dúvida, escreva os valores já no tipo que a função vai ler: `1.0` em vez de `1` para um `double`, `(long)x` para um `long`, `(char *)NULL` para um ponteiro. O compilador não confere os argumentos do `...`, então essa é a única garantia de que o `va_arg` vai ler o valor certo
