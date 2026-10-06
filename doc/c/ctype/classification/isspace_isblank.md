**isspace / isblank**

> `ctype.h`

O `isspace` e o `isblank` verificam se um caractere é um espaço em branco. O `isspace` considera todos os caracteres que separam texto, inclusive quebras de linha, enquanto o `isblank` considera só os que separam palavras dentro de uma mesma linha

```c
int isspace(int c);
int isblank(int c);
```

- `c`: o caractere a ser verificado, convertido para `unsigned char`, ou `EOF` (ver `../summary.md`)

| Caractere | Nome | `isspace` | `isblank` |
|-----------|------|-----------|-----------|
| `' '` | espaço | sim | sim |
| `'\t'` | tab horizontal | sim | sim |
| `'\n'` | nova linha | sim | não |
| `'\v'` | tab vertical | sim | não |
| `'\f'` | form feed (nova página) | sim | não |
| `'\r'` | carriage return | sim | não |

- `isspace(c)`: diferente de `0` para os seis caracteres da tabela
- `isblank(c)`: diferente de `0` só para o espaço e o `\t` (adicionado no C99)
- É o mesmo critério que o `scanf` usa para pular espaços com `%d` ou `%s`, e o `strtol` para ignorar espaços no começo da string

```c
isspace(' ');    // verdadeiro
isspace('\n');   // verdadeiro
isblank('\n');   // falso
isspace('a');    // falso
```

---

**Removendo espaços do começo e do fim (trim)**

```c
#include <ctype.h>
#include <string.h>

char *trim(char *s) {
  while (isspace((unsigned char)*s)) {
    s++;                                   // avança o início
  }
  if (*s == '\0') {
    return s;                              // a string só tinha espaços
  }
  char *fim = s + strlen(s) - 1;
  while (fim > s && isspace((unsigned char)*fim)) {
    fim--;                                 // recua o fim
  }
  fim[1] = '\0';
  return s;
}

char buf[] = "  pato \n";
char *limpo = trim(buf);   // "pato"
```

- O ponteiro devolvido aponta para dentro do mesmo buffer. Se a string tiver sido alocada com `malloc`, o `free` deve receber o ponteiro **original**, e não o devolvido pelo `trim`
- Usar `isspace` no fim também remove o `\n` deixado pelo `fgets` e o `\r` de arquivos vindos do Windows

---

**Contando palavras**

```c
int contar_palavras(const char *s) {
  int palavras = 0, dentro = 0;
  for (; *s != '\0'; s++) {
    if (isspace((unsigned char)*s)) {
      dentro = 0;
    } else if (!dentro) {
      dentro = 1;                          // começou uma palavra nova
      palavras++;
    }
  }
  return palavras;
}

contar_palavras("  o pato\tnada \n");   // 3
```

> Use `isspace` quando o texto pode ter várias linhas e qualquer separação conta, e `isblank` quando se está processando uma única linha e a quebra de linha tem significado próprio, como ao separar os campos de uma linha de um arquivo
