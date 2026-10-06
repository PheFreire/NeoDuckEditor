**TextLength**

> `raylib.h` — módulo `rtext`

O `TextLength` devolve o tamanho de uma string em **bytes**, contando até o `\0`. É o equivalente do `strlen` dentro do raylib

```c
unsigned int TextLength(const char *text);
```

- `text`: a string, terminada em `\0`

- Devolve a quantidade de bytes antes do `\0`
- Com `text == NULL`, devolve `0` (o `strlen` com `NULL` é comportamento indefinido)
- Conta bytes, e não caracteres: em UTF-8, letras acentuadas ocupam 2 bytes

```c
TextLength("raylib");   // 6
TextLength("ação");     // 6: 'ç' e 'ã' têm 2 bytes cada
TextLength(NULL);       // 0
```

> Para contar caracteres (o que o usuário vê) em um texto UTF-8, percorra a string com `GetCodepoint` (ver `../unicode.md`). Fora do raylib, o mesmo comportamento em bytes é o do `strlen` (ver `../../../string/strlen.md`)
