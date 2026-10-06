**LoadFileText**

> `raylib.h` — módulo `rcore`

O `LoadFileText` lê um arquivo de texto inteiro e devolve o conteúdo como uma string terminada em `\0`

```c
char *LoadFileText(const char *fileName);
```

- `fileName`: o caminho do arquivo

- Devolve a string alocada pelo raylib, ou `NULL` se o arquivo não puder ser lido
- A string pode ser modificada pelo programa (por exemplo, com `strtok`)
- Precisa ser liberada com `UnloadFileText`

```c
char *dialogo = LoadFileText("dialogos/intro.txt");
if (dialogo != NULL) {
  DrawText(dialogo, 20, 300, 20, WHITE);   // o \n do arquivo quebra as linhas
  UnloadFileText(dialogo);
}
```

> Se o arquivo contiver um byte `\0` no meio (um arquivo binário), a string termina ali. Para arquivos que não são texto, use o `LoadFileData` (ver `../file-text.md`)
