**GetCharPressed**

> `raylib.h` — módulo `rcore`

O `GetCharPressed` devolve o próximo **caractere** digitado neste frame, como um codepoint Unicode, tirado de uma fila interna. É a função certa para campos de texto, pois já aplica o layout do teclado, o Shift, o Caps Lock e os acentos

```c
int GetCharPressed(void);
```

- Devolve o codepoint Unicode do caractere (`'a'` = 97, `'á'` = 225, `'€'` = 8364) e o remove da fila
- Devolve `0` quando a fila está vazia
- Teclas que não geram caractere (setas, Shift, Backspace, Enter) não entram nessa fila

```c
char texto[64] = "";
int tamanho = 0;

int c = GetCharPressed();
while (c > 0) {
  if (c >= 32 && c < 127 && tamanho < (int)sizeof(texto) - 1) {   // só ASCII imprimível
    texto[tamanho++] = (char)c;
    texto[tamanho] = '\0';
  }
  c = GetCharPressed();
}

if ((IsKeyPressed(KEY_BACKSPACE) || IsKeyPressedRepeat(KEY_BACKSPACE)) && tamanho > 0) {
  texto[--tamanho] = '\0';
}

DrawText(texto, 100, 200, 30, DARKGRAY);
```

---

**Aceitando acentos (UTF-8)**

Um codepoint acima de `127` ocupa mais de um byte em UTF-8. Para guardá-lo em uma string, converta com `CodepointToUTF8`:

```c
int c = GetCharPressed();
while (c > 0) {
  int bytes = 0;
  const char *utf8 = CodepointToUTF8(c, &bytes);   // 'á' vira 2 bytes: 0xC3 0xA1
  if (tamanho + bytes < (int)sizeof(texto)) {
    memcpy(texto + tamanho, utf8, bytes);
    tamanho += bytes;
    texto[tamanho] = '\0';
  }
  c = GetCharPressed();
}
```

- Para apagar com Backspace, é preciso remover o caractere inteiro, e não só o último byte (ver `../../text/unicode.md`)
- Para desenhar acentos, a fonte precisa ter esses caracteres carregados (ver `../../text/functions/load-font-ex.md`)

> O laço `while (c > 0)` é importante: se o usuário digitar rápido, mais de um caractere pode chegar no mesmo frame, e ler só um por frame faria o campo "atrasar" ou perder letras
