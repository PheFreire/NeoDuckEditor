**GetMonitorName**

> `raylib.h` — módulo `rcore`

O `GetMonitorName` devolve o nome legível de um monitor, como informado pelo sistema operacional (`"DELL U2720Q"`, `"Built-in Retina Display"`). É usado para mostrar uma lista de monitores em um menu de opções

```c
const char *GetMonitorName(int monitor);
```

- `monitor`: índice do monitor, de `0` a `GetMonitorCount() - 1`

- Devolve o nome do monitor, em UTF-8, terminado em `\0`
- Um índice inválido gera um aviso no log e devolve uma string vazia (`""`)
- A string pertence ao sistema de janelas: não a modifique nem chame `free` nela

```c
for (int i = 0; i < GetMonitorCount(); i++) {
  DrawText(TextFormat("%d: %s", i, GetMonitorName(i)), 20, 40 + i * 30, 20,
           i == GetCurrentMonitor() ? RED : DARKGRAY);
}
```

> O ponteiro pode deixar de ser válido se o monitor for desconectado. Para guardar o nome (por exemplo, em um arquivo de configuração), copie a string com `strncpy` ou `strdup` (ver `../../../string/strdup.md`)
