**Clipboard**

> `raylib.h` — módulo `rcore`

O clipboard (área de transferência) é o lugar onde o sistema operacional guarda o que foi copiado com `Ctrl+C` / `Cmd+C`. O raylib permite ler e escrever texto nele, para implementar "copiar" e "colar" dentro do jogo, como em campos de texto, códigos de convite ou seeds de mapa

```c
void SetClipboardText(const char *text);
const char *GetClipboardText(void);
```

- `SetClipboardText`: substitui o conteúdo do clipboard pelo texto, que pode ser colado em qualquer outro programa
- `GetClipboardText`: devolve o texto atual do clipboard, inclusive se ele foi copiado em outro programa
- Ambas precisam da janela criada, pois o clipboard é acessado pelo sistema de janelas

---

**Copiar e colar em um campo de texto**

```c
char texto[256] = "";

bool ctrl = IsKeyDown(KEY_LEFT_CONTROL) || IsKeyDown(KEY_LEFT_SUPER);  // Ctrl ou Cmd

if (ctrl && IsKeyPressed(KEY_C)) {
  SetClipboardText(texto);
}

if (ctrl && IsKeyPressed(KEY_V)) {
  const char *colado = GetClipboardText();
  if (colado != NULL) {
    strncat(texto, colado, sizeof(texto) - strlen(texto) - 1);
  }
}
```

- `KEY_LEFT_SUPER` é a tecla Cmd no macOS e a tecla Windows no Windows/Linux
- O `strncat` com o espaço restante evita estourar o buffer quando o texto colado é grande (ver `../../string/concatenation/strncat.md`)

---

**Armadilhas**

- O ponteiro devolvido por `GetClipboardText` pertence ao sistema de janelas (GLFW). Não chame `free` nele e copie o texto se precisar guardá-lo, pois ele pode mudar na próxima chamada
- O clipboard pode estar vazio ou conter algo que não é texto (uma imagem copiada). Nesses casos, o retorno pode ser `NULL` ou uma string vazia, então sempre verifique antes de usar
- O texto está em UTF-8: letras acentuadas ocupam mais de um byte, e o `strlen` conta bytes, e não caracteres (ver `../text/unicode.md`)

> O raylib 5.5 também tem `GetClipboardImage`, que lê uma imagem do clipboard, mas o suporte depende da plataforma (funciona no Windows, e não em todas as outras). Para portabilidade, trate o clipboard como texto
