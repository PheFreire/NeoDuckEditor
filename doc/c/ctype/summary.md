**ctype.h**

> `ctype.h`

A `ctype.h` é a biblioteca do C para classificar e converter caracteres: saber se um caractere é letra, dígito, espaço ou pontuação, e trocar entre maiúscula e minúscula. É usada principalmente para validar e processar texto caractere por caractere, como ao ler a entrada do usuário ou separar palavras

> Um `char` em C é apenas um número de 1 byte. O caractere `'A'` é o número `65`, `'a'` é `97` e `'0'` é `48`, segundo a tabela ASCII. As funções da `ctype.h` olham para esse número e dizem a que categoria ele pertence

```c
#include <ctype.h>
```

- Não precisa de nenhuma flag de compilação extra, faz parte da biblioteca padrão

**Funções**

| Função | Verdadeiro para | Ver |
|--------|-----------------|-----|
| `isalpha(c)` | letras `a-z` e `A-Z` | `classification/isalpha_isdigit_isalnum.md` |
| `isdigit(c)` | dígitos `0-9` | `classification/isalpha_isdigit_isalnum.md` |
| `isalnum(c)` | letras ou dígitos | `classification/isalpha_isdigit_isalnum.md` |
| `isxdigit(c)` | dígitos hexadecimais `0-9`, `a-f`, `A-F` | `classification/isalpha_isdigit_isalnum.md` |
| `isupper(c)` | letras maiúsculas `A-Z` | `classification/isupper_islower.md` |
| `islower(c)` | letras minúsculas `a-z` | `classification/isupper_islower.md` |
| `isspace(c)` | espaço, `\t`, `\n`, `\v`, `\f`, `\r` | `classification/isspace_isblank.md` |
| `isblank(c)` | espaço e `\t` | `classification/isspace_isblank.md` |
| `ispunct(c)` | pontuação: `!`, `,`, `.`, `@`, `#`... | `classification/isprint_isgraph_ispunct_iscntrl.md` |
| `isprint(c)` | caracteres visíveis e o espaço | `classification/isprint_isgraph_ispunct_iscntrl.md` |
| `isgraph(c)` | caracteres visíveis, sem o espaço | `classification/isprint_isgraph_ispunct_iscntrl.md` |
| `iscntrl(c)` | caracteres de controle (`0-31` e `127`) | `classification/isprint_isgraph_ispunct_iscntrl.md` |
| `toupper(c)` | converte para maiúscula | `conversion/toupper_tolower.md` |
| `tolower(c)` | converte para minúscula | `conversion/toupper_tolower.md` |

**Como todas funcionam**

```c
int isalpha(int c);
int toupper(int c);
```

- Recebem um `int`, e não um `char`, para aceitar também o `EOF` devolvido por funções como `getchar`
- As funções `is*` devolvem **diferente de zero** se o caractere pertence à categoria, e `0` se não pertence. O valor verdadeiro não é necessariamente `1` (na glibc pode ser `1024`, por exemplo), então use o resultado só como condição, e nunca compare com `== 1`
- As funções `to*` devolvem o caractere convertido, ou o próprio caractere se não houver conversão

```c
if (isdigit(c)) {        // certo
}
if (isdigit(c) == 1) {   // errado: pode ser verdadeiro e diferente de 1
}
```

**O mapa da tabela ASCII**

```text
0-31, 127    controle      iscntrl          (\0, \t, \n, \r, ESC...)
32           espaço        isspace, isprint, isblank
33-47        pontuação     ispunct          ! " # $ % & ' ( ) * + , - . /
48-57        dígitos       isdigit          0 1 2 3 4 5 6 7 8 9
58-64        pontuação     ispunct          : ; < = > ? @
65-90        maiúsculas    isupper          A ... Z
91-96        pontuação     ispunct          [ \ ] ^ _ `
97-122       minúsculas    islower          a ... z
123-126      pontuação     ispunct          { | } ~
```

- `isalpha` = `isupper` + `islower`, `isalnum` = `isalpha` + `isdigit`, `isgraph` = `isalnum` + `ispunct`, `isprint` = `isgraph` + espaço

**O cast para unsigned char**

O argumento precisa ser um valor que caiba em um `unsigned char` (`0` a `255`) ou o `EOF`. Qualquer outro valor negativo é **comportamento indefinido**:

```c
char c = 'é';          // em UTF-8 é mais de um byte, e cada byte vale de 128 a 255
isalpha(c);            // ERRADO: se char for signed, o byte vira negativo
isalpha((unsigned char)c);   // certo
```

- Em x86, `char` costuma ser `signed`, e bytes acima de `127` (letras acentuadas em UTF-8 ou Latin-1) viram números negativos. Muitas implementações usam o valor como índice de uma tabela, e um índice negativo lê memória fora dela
- Ao percorrer uma string, sempre converta cada `char` para `unsigned char` antes de passar para a `ctype.h`
- O valor devolvido por `getchar` já está no formato certo (`0` a `255` ou `EOF`) e pode ser passado diretamente

**Locale e acentos**

- Por padrão, o programa roda no locale `"C"`, onde só os caracteres ASCII são classificados: `isalpha` é verdadeiro apenas para `a-z` e `A-Z`
- Com `setlocale(LC_ALL, "")` (de `locale.h`), as funções passam a seguir o idioma do sistema, mas continuam trabalhando com **um byte por vez**. Em UTF-8, letras acentuadas ocupam 2 bytes ou mais, então `isalpha` não consegue reconhecê-las de qualquer forma
- Para texto Unicode, a `wctype.h` tem as versões para caracteres largos (`iswalpha`, `towupper`), que trabalham com `wchar_t`

> As funções da `ctype.h` costumam ser implementadas como macros que consultam uma tabela, sendo bem mais rápidas e legíveis que comparações manuais como `c >= 'a' && c <= 'z'`. Além disso, essas comparações manuais assumem que as letras são consecutivas, o que é verdade no ASCII, mas não é garantido pelo padrão C (a única garantia é para os dígitos `'0'` a `'9'`)
