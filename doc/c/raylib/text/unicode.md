**Unicode e UTF-8**

> `raylib.h` — módulo `rtext`

O raylib trabalha com texto em UTF-8, a codificação usada pelos arquivos de código, pelo terminal e pela maioria dos sistemas. Em UTF-8, cada caractere (um **codepoint** Unicode) ocupa de 1 a 4 bytes, o que muda a forma de contar, percorrer e apagar caracteres em uma string C

```text
caractere   codepoint   bytes em UTF-8
   a         97 (0x61)   61                  1 byte
   ã         227 (0xE3)  C3 A3               2 bytes
   €         8364        E2 82 AC            3 bytes
   😀        128512      F0 9F 98 80         4 bytes
```

- Caracteres ASCII (inglês, números, pontuação) ocupam 1 byte, igual ao ASCII tradicional
- Letras acentuadas do português ocupam 2 bytes

---

**Bytes não são caracteres**

```c
const char *s = "ação";
strlen(s);       // 6: bytes ('a', 2 de 'ç', 2 de 'ã', 'o')
TextLength(s);   // 6: também conta bytes
```

- `strlen` e `TextLength` contam **bytes**. Para contar caracteres, percorra a string com `GetCodepoint`:

```c
int contar_caracteres(const char *s) {
  int total = 0;
  while (*s) {
    int bytes = 0;
    GetCodepoint(s, &bytes);   // lê um caractere e informa quantos bytes ele ocupa
    s += bytes;
    total++;
  }
  return total;
}
// contar_caracteres("ação") == 4
```

---

**Funções**

| Função | Faz |
|--------|-----|
| `GetCodepoint(texto, &bytes)` | lê o próximo caractere do texto e informa quantos bytes ele ocupa |
| `CodepointToUTF8(codepoint, &bytes)` | converte um codepoint para os bytes UTF-8 |
| `LoadCodepoints(texto, &n)` | converte um texto inteiro em um array de codepoints |
| `GetCharPressed()` | o caractere digitado, como codepoint (ver `../input/functions/get-char-pressed.md`) |

---

**Apagar o último caractere (Backspace)**

```c
// remove o último caractere UTF-8, e não só o último byte
void apagar_ultimo(char *s) {
  int n = (int)strlen(s);
  if (n == 0) return;
  n--;
  while (n > 0 && ((unsigned char)s[n] & 0xC0) == 0x80) {
    n--;   // bytes de continuação começam com 10xxxxxx
  }
  s[n] = '\0';
}
```

- Apagar só o último byte de um `ã` deixa um byte solto, que aparece como `?` ou um símbolo estranho

---

**Desenhando acentos**

- A fonte padrão já tem os caracteres do Latin-1, incluindo os acentos do português
- Fontes carregadas com `LoadFontEx(..., NULL, 0)` têm só o ASCII: acentos aparecem como `?`. Inclua os caracteres necessários na lista de codepoints (ver `font-loading.md`)
- O arquivo `.c` precisa estar salvo em UTF-8 para que strings como `"ação"` no código tenham os bytes certos

> As funções da `ctype.h` (`isalpha`, `toupper`) trabalham com um byte por vez e não reconhecem letras acentuadas em UTF-8 (ver `../../ctype/summary.md`). Para texto Unicode, trabalhe com os codepoints
