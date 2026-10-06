**CodepointToUTF8**

> `raylib.h` — módulo `rtext`

O `CodepointToUTF8` converte um codepoint Unicode (um número que identifica um caractere) na sequência de bytes UTF-8 que o representa. É usado para montar strings a partir de caracteres digitados ou calculados

```c
const char *CodepointToUTF8(int codepoint, int *utf8Size);
```

- `codepoint`: o caractere, como número Unicode (`'a'` = 97, `'ã'` = 227, `'€'` = 8364)
- `utf8Size`: ponteiro onde é escrito quantos bytes a sequência tem (1 a 4)

- Devolve um ponteiro para os bytes UTF-8 em um buffer estático interno
- O buffer **não** termina com `\0` de forma confiável: use sempre o `utf8Size` para saber quantos bytes copiar
- A próxima chamada sobrescreve o buffer

```c
// adicionar o caractere digitado a uma string
char texto[128] = "";
int tamanho = 0;

int c = GetCharPressed();
while (c > 0) {
  int bytes = 0;
  const char *utf8 = CodepointToUTF8(c, &bytes);
  if (tamanho + bytes < (int)sizeof(texto)) {
    memcpy(texto + tamanho, utf8, bytes);   // copia exatamente os bytes do caractere
    tamanho += bytes;
    texto[tamanho] = '\0';
  }
  c = GetCharPressed();
}
```

> O caminho inverso, ler um caractere de uma string UTF-8 e obter o codepoint, é feito pelo `GetCodepoint` (ver `get-codepoint.md` e `../unicode.md`)
