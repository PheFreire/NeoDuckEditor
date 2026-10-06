**isalpha / isdigit / isalnum / isxdigit**

> `ctype.h`

O `isalpha`, o `isdigit`, o `isalnum` e o `isxdigit` verificam se um caractere é uma letra, um dígito decimal, uma letra ou dígito, ou um dígito hexadecimal. São as funções mais usadas para validar entradas, como conferir se um texto é um número ou um nome válido

```c
int isalpha(int c);
int isdigit(int c);
int isalnum(int c);
int isxdigit(int c);
```

- `c`: o caractere a ser verificado, convertido para `unsigned char`, ou `EOF` (ver `../summary.md`)

- `isalpha(c)`: diferente de `0` se `c` for uma letra (`a-z` ou `A-Z` no locale padrão)
- `isdigit(c)`: diferente de `0` se `c` for um dígito de `'0'` a `'9'`
- `isalnum(c)`: diferente de `0` se `c` for uma letra ou um dígito, ou seja, `isalpha(c) || isdigit(c)`
- `isxdigit(c)`: diferente de `0` se `c` for um dígito hexadecimal: `0-9`, `a-f` ou `A-F`
- Todas devolvem `0` para `EOF`

```c
isalpha('a');   // verdadeiro
isalpha('7');   // falso
isdigit('7');   // verdadeiro
isdigit('x');   // falso
isalnum('_');   // falso: o sublinhado é pontuação
isxdigit('F');  // verdadeiro
isxdigit('g');  // falso
```

**Verificando se uma string é um número inteiro**

```c
#include <ctype.h>

int so_digitos(const char *s) {
  if (*s == '\0') {
    return 0;                              // string vazia não é número
  }
  for (; *s != '\0'; s++) {
    if (!isdigit((unsigned char)*s)) {
      return 0;
    }
  }
  return 1;
}

so_digitos("2026");   // 1
so_digitos("20a6");   // 0
so_digitos("-5");     // 0: o sinal não é dígito
```

- Para aceitar sinal, espaços e checar overflow, o `strtol` é mais completo (ver `../../string/casting/strtol.md`)

**Convertendo um dígito em número**

```c
char c = '7';
if (isdigit((unsigned char)c)) {
  int valor = c - '0';   // 7
}
```

- Funciona porque o padrão C garante que os caracteres `'0'` a `'9'` são consecutivos. `'7' - '0'` é `55 - 48 = 7`
- Essa garantia **não** existe para letras, então para converter um dígito hexadecimal é melhor usar `strtol` com base `16`

**Validando um identificador**

```c
int identificador_valido(const char *s) {
  if (!isalpha((unsigned char)s[0]) && s[0] != '_') {
    return 0;                              // precisa começar com letra ou _
  }
  for (int i = 1; s[i] != '\0'; i++) {
    if (!isalnum((unsigned char)s[i]) && s[i] != '_') {
      return 0;
    }
  }
  return 1;
}
```

> No locale padrão (`"C"`), o `isalpha` reconhece só as 52 letras ASCII. Letras acentuadas como `é` e `ç` não são reconhecidas, e em UTF-8 elas nem cabem em um único `char` (ver `../summary.md`)
