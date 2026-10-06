**TextFormat**

> `raylib.h` — módulo `rtext`

O `TextFormat` monta uma string formatada com variáveis, no mesmo estilo do `printf`, e devolve um ponteiro para um buffer interno do raylib. É a forma prática de desenhar texto com números e valores sem declarar um array para cada texto

```c
const char *TextFormat(const char *text, ...);
```

- `text`: o texto de formato, com os especificadores do `printf` (`%d`, `%.2f`, `%s`...)
- `...`: os valores para os especificadores

- Devolve um ponteiro para o texto formatado, em um buffer **estático** do raylib
- O raylib usa 4 buffers que se alternam: a 5ª chamada sobrescreve o resultado da 1ª
- Cada buffer tem um tamanho máximo (1024 bytes por padrão). Textos maiores são cortados

```c
DrawText(TextFormat("Pontos: %d", pontos), 10, 10, 20, BLACK);
DrawText(TextFormat("Posição: (%.1f, %.1f)", pos.x, pos.y), 10, 40, 20, GRAY);
DrawText(TextFormat("Jogador: %s", nome), 10, 70, 20, BLUE);
```

---

**O buffer é temporário**

```c
const char *a = TextFormat("%d", 1);
const char *b = TextFormat("%d", 2);
const char *c = TextFormat("%d", 3);
const char *d = TextFormat("%d", 4);
const char *e = TextFormat("%d", 5);   // reutiliza o buffer de 'a'
// agora a aponta para "5"
```

- Use o resultado na hora (passando direto para `DrawText`, `SetWindowTitle`, `TraceLog`)
- Para guardar o texto, copie para um array próprio com `snprintf` ou `strncpy`:

```c
char titulo[64];
snprintf(titulo, sizeof(titulo), "Fase %d", fase);   // fica guardado enquanto o array existir
```

> O `TextFormat` não é thread-safe e não deve ser liberado com `free`. É um atalho para o caso comum de "formatar e desenhar agora", e não um substituto do `snprintf` (ver `../../../string/casting/snprintf.md`)
