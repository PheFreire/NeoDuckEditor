**SetClipboardText**

> `raylib.h` — módulo `rcore`

O `SetClipboardText` coloca um texto na área de transferência do sistema operacional, como se o usuário tivesse feito `Ctrl+C`. O texto pode então ser colado em qualquer outro programa

```c
void SetClipboardText(const char *text);
```

- `text`: o texto a copiar, em UTF-8, terminado em `\0`

- Não devolve nada
- Substitui todo o conteúdo atual do clipboard
- O texto é copiado pelo sistema, então o buffer original pode ser alterado ou liberado depois da chamada

```c
// botão "copiar código da sala"
if (IsKeyPressed(KEY_C) && IsKeyDown(KEY_LEFT_CONTROL)) {
  SetClipboardText(TextFormat("SALA-%04d", codigo_sala));
  mensagem = "código copiado!";
}
```

> Precisa da janela criada, pois o clipboard é acessado pelo sistema de janelas. Ver `../clipboard.md` para copiar e colar em um campo de texto completo
