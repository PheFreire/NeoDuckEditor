**isprint / isgraph / ispunct / iscntrl**

> `ctype.h`

O `isprint`, o `isgraph`, o `ispunct` e o `iscntrl` dividem os caracteres entre os que aparecem na tela e os que não aparecem. São úteis para mostrar dados que podem conter bytes invisíveis, limpar a entrada do usuário e identificar pontuação ao separar palavras

```c
int isprint(int c);
int isgraph(int c);
int ispunct(int c);
int iscntrl(int c);
```

- `c`: o caractere a ser verificado, convertido para `unsigned char`, ou `EOF` (ver `../summary.md`)

- `isprint(c)`: diferente de `0` se `c` ocupa espaço na tela ao ser impresso: letras, dígitos, pontuação **e o espaço** (ASCII `32` a `126`)
- `isgraph(c)`: igual ao `isprint`, mas **sem o espaço**: só caracteres que deixam uma marca visível (ASCII `33` a `126`)
- `ispunct(c)`: diferente de `0` se `c` for visível, mas não for letra nem dígito: `! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ { | } ~` e a crase
- `iscntrl(c)`: diferente de `0` se `c` for um caractere de controle, que não é impresso e sim interpretado pelo terminal: ASCII `0` a `31` e `127` (`\0`, `\t`, `\n`, `\r`, `ESC`, `DEL`...)

```text
         iscntrl                  isprint
    ┌────────────────┐ ┌───────────────────────────────┐
    0 ... 31     127   32    33 ......................... 126
                       espaço └────────── isgraph ─────────┘
                              isalnum + ispunct
```

- No ASCII, todo caractere é exatamente um dos dois: de controle (`iscntrl`) ou imprimível (`isprint`)
- O `\t` e o `\n` são de controle, e não imprimíveis, mesmo sendo espaço em branco para o `isspace`

```c
isprint(' ');    // verdadeiro
isgraph(' ');    // falso
ispunct('!');    // verdadeiro
ispunct('a');    // falso
iscntrl('\n');   // verdadeiro
isprint('\n');   // falso
```

**Mostrando bytes invisíveis**

Ao imprimir dados que podem ter qualquer byte (um arquivo binário, uma mensagem recebida pela rede), os caracteres de controle podem bagunçar o terminal. Mostrá-los como código evita isso:

```c
void mostrar(const char *buf, size_t n) {
  for (size_t i = 0; i < n; i++) {
    unsigned char c = (unsigned char)buf[i];
    if (isprint(c)) {
      putchar(c);
    } else {
      printf("\\x%02x", c);                // ex: \x0a para \n, \x1b para ESC
    }
  }
  putchar('\n');
}

mostrar("ola\n\x1b[31m", 9);   // ola\x0a\x1b[31m
```

**Removendo pontuação**

```c
void sem_pontuacao(char *s) {
  char *destino = s;
  for (; *s != '\0'; s++) {
    if (!ispunct((unsigned char)*s)) {
      *destino++ = *s;                     // copia só o que não é pontuação
    }
  }
  *destino = '\0';
}

char frase[] = "ola, mundo!";
sem_pontuacao(frase);   // "ola mundo"
```

> O `ispunct` considera o sublinhado (`_`) e o hífen (`-`) como pontuação. Ao separar palavras em um texto que contém identificadores (`nome_completo`) ou palavras compostas (`guarda-chuva`), trate esses caracteres separadamente
