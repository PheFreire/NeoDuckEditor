**toupper / tolower**

> `ctype.h`

O `toupper` e o `tolower` convertem um caractere para maiúscula ou minúscula. Recebem e devolvem **um** caractere, então para converter uma string inteira é preciso percorrê-la e aplicar a função em cada posição

```c
int toupper(int c);
int tolower(int c);
```

- `c`: o caractere a ser convertido, convertido para `unsigned char`, ou `EOF` (ver `../summary.md`)

- `toupper(c)`: se `c` for uma letra minúscula, devolve a maiúscula correspondente. Caso contrário, devolve o próprio `c`
- `tolower(c)`: se `c` for uma letra maiúscula, devolve a minúscula correspondente. Caso contrário, devolve o próprio `c`
- Não altera nada: o resultado precisa ser guardado ou usado
- Dígitos, espaços, pontuação e `EOF` passam sem mudança, então não é preciso checar com `islower`/`isupper` antes

```c
toupper('a');   // 'A'
toupper('A');   // 'A': já era maiúscula
toupper('7');   // '7': não é letra
tolower('Q');   // 'q'
```

**Convertendo uma string**

```c
#include <ctype.h>

void maiusculas(char *s) {
  for (; *s != '\0'; s++) {
    *s = (char)toupper((unsigned char)*s);
  }
}

char nome[] = "o pato";
maiusculas(nome);   // "O PATO"
```

- A string precisa ser modificável: chamar `maiusculas("o pato")` diretamente com uma string literal escreve em memória somente leitura e derruba o programa
- O cast para `unsigned char` na entrada evita comportamento indefinido com bytes acima de `127`, e o cast para `char` na saída deixa explícita a conversão de volta

**Comparando sem diferenciar maiúsculas**

```c
int iguais_sem_caixa(const char *a, const char *b) {
  while (*a != '\0' && *b != '\0') {
    if (tolower((unsigned char)*a) != tolower((unsigned char)*b)) {
      return 0;
    }
    a++;
    b++;
  }
  return *a == *b;                         // as duas terminaram juntas
}

iguais_sem_caixa("Pato", "pATO");   // 1
```

- No Linux e no macOS, o `strcasecmp` (de `strings.h`, POSIX) já faz essa comparação e devolve o mesmo resultado que o `strcmp` (ver `../../string/strcmp.md`), mas não faz parte do padrão C

**Respostas de sim ou não**

```c
int c = getchar();
if (tolower(c) == 's') {
  // aceita 's' e 'S'
}
```

- O retorno do `getchar` já está no formato certo e pode ser passado direto, inclusive quando é `EOF`

> No locale padrão, só as letras ASCII são convertidas: `toupper('é')` não devolve `'É'`, e em UTF-8 o `é` nem é um único `char`. Para texto com acentos, é preciso trabalhar com `wchar_t` e as funções `towupper`/`towlower` de `wctype.h` (ver `../summary.md`)
