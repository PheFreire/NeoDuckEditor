**GetCodepoint**

> `raylib.h` — módulo `rtext`

O `GetCodepoint` lê o próximo caractere de uma string UTF-8 e devolve o codepoint Unicode dele, informando quantos bytes o caractere ocupa. É a forma de percorrer um texto UTF-8 caractere por caractere

```c
int GetCodepoint(const char *text, int *codepointSize);
```

- `text`: ponteiro para o início do caractere a ler
- `codepointSize`: ponteiro onde é escrito quantos bytes o caractere ocupa (1 a 4)

- Devolve o codepoint do caractere
- Em uma sequência UTF-8 inválida, devolve `0x3f` (`'?'`)

```c
const char *s = "ação";
while (*s) {
  int bytes = 0;
  int cp = GetCodepoint(s, &bytes);
  TraceLog(LOG_INFO, "U+%04X ocupa %d byte(s)", cp, bytes);
  s += bytes;   // avança para o próximo caractere
}
// U+0061 1, U+00E7 2, U+00E3 2, U+006F 1
```

---

**Efeito máquina de escrever**

```c
// mostra o texto caractere por caractere, sem cortar um acento no meio
int visiveis = (int)(GetTime() * 20);   // 20 caracteres por segundo
const char *p = texto;
for (int i = 0; i < visiveis && *p; i++) {
  int b = 0;
  GetCodepoint(p, &b);
  p += b;
}
int bytes_visiveis = (int)(p - texto);
DrawText(TextSubtext(texto, 0, bytes_visiveis), 20, 400, 20, WHITE);
```

> Avançar o ponteiro pelo `codepointSize`, e não de 1 em 1 byte, é o que impede que caracteres de vários bytes sejam cortados ao meio (ver `../unicode.md`)
