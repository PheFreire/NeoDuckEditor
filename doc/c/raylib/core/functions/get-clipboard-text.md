**GetClipboardText**

> `raylib.h` — módulo `rcore`

O `GetClipboardText` lê o texto atual da área de transferência do sistema operacional, como se o usuário tivesse feito `Ctrl+V`. O texto pode ter sido copiado em qualquer programa

```c
const char *GetClipboardText(void);
```

- Devolve o texto do clipboard, em UTF-8, terminado em `\0`
- Pode devolver `NULL` (ou uma string vazia) se o clipboard estiver vazio ou contiver algo que não é texto
- A string pertence ao sistema de janelas: não modifique, não chame `free`, e copie se precisar guardá-la

```c
char seed[32] = "";

if (IsKeyDown(KEY_LEFT_CONTROL) && IsKeyPressed(KEY_V)) {
  const char *colado = GetClipboardText();
  if (colado != NULL) {
    snprintf(seed, sizeof(seed), "%s", colado);   // copia limitando ao tamanho do buffer
  }
}
```

---

**Armadilhas**

- O texto pode ter qualquer tamanho. Copiar com `strcpy` para um buffer fixo pode estourar a memória. Use `snprintf` ou `strncat` com o tamanho do destino (ver `../../../string/casting/snprintf.md`)
- O texto pode ter quebras de linha (`\n` ou `\r\n`), tabs e caracteres de controle. Em um campo de uma linha só, remova ou substitua esses caracteres antes de usar
- O ponteiro é sobrescrito na próxima chamada, então duas chamadas seguidas não devem ser comparadas pelo ponteiro, e sim pelo conteúdo com `strcmp`

> Ver `../clipboard.md` para o exemplo completo de copiar e colar com `Ctrl`/`Cmd`
