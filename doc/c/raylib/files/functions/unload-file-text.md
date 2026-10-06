**UnloadFileText**

> `raylib.h` — módulo `rcore`

O `UnloadFileText` libera a string alocada pelo `LoadFileText`

```c
void UnloadFileText(char *text);
```

- `text`: o ponteiro devolvido pelo `LoadFileText`

- Não devolve nada

```c
char *cfg = LoadFileText("config.txt");
if (cfg != NULL) {
  ler_configuracoes(cfg);
  UnloadFileText(cfg);
}
```

> Depois do `UnloadFileText`, qualquer ponteiro para dentro do texto (como os devolvidos pelo `strtok` ou pelo `strstr`) também fica inválido. Copie as partes que precisar guardar antes de liberar
