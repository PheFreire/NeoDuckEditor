**isupper / islower**

> `ctype.h`

O `isupper` e o `islower` verificam se um caractere é uma letra maiúscula ou minúscula. São usados junto com o `toupper` e o `tolower` para normalizar texto, e para validar regras como "a senha precisa ter uma letra maiúscula"

```c
int isupper(int c);
int islower(int c);
```

- `c`: o caractere a ser verificado, convertido para `unsigned char`, ou `EOF` (ver `../summary.md`)

- `isupper(c)`: diferente de `0` se `c` for uma letra maiúscula (`A-Z` no locale padrão)
- `islower(c)`: diferente de `0` se `c` for uma letra minúscula (`a-z` no locale padrão)
- Para qualquer caractere que não seja letra (dígitos, espaço, pontuação), os dois devolvem `0`
- Por isso `!isupper(c)` **não** significa "é minúscula": um dígito também não é maiúsculo

```c
isupper('A');   // verdadeiro
isupper('a');   // falso
islower('a');   // verdadeiro
isupper('7');   // falso
islower('7');   // falso: não é letra
```

---

**Validando uma senha**

```c
#include <ctype.h>

int senha_forte(const char *s) {
  int maiuscula = 0, minuscula = 0, digito = 0;
  for (; *s != '\0'; s++) {
    unsigned char c = (unsigned char)*s;
    if (isupper(c)) maiuscula = 1;
    if (islower(c)) minuscula = 1;
    if (isdigit(c)) digito = 1;
  }
  return maiuscula && minuscula && digito;
}
```

---

**Contando maiúsculas e minúsculas**

```c
const char *texto = "Ola Mundo";
int mai = 0, min = 0;
for (int i = 0; texto[i] != '\0'; i++) {
  unsigned char c = (unsigned char)texto[i];
  if (isupper(c)) mai++;
  else if (islower(c)) min++;
}
// mai == 2, min == 6 (o espaço não conta em nenhum)
```

> Para converter, e não só verificar, use o `toupper` e o `tolower` (ver `../conversion/toupper_tolower.md`). Eles já deixam intactos os caracteres que não são letras, então não é preciso checar com `isupper`/`islower` antes de chamar
