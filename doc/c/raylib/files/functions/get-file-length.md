**GetFileLength**

> `raylib.h` — módulo `rcore`

O `GetFileLength` devolve o tamanho de um arquivo, em bytes, sem precisar carregá-lo

```c
int GetFileLength(const char *fileName);
```

- `fileName`: o caminho do arquivo

- Devolve o tamanho em bytes, ou `0` se o arquivo não existir
- O nome não é `GetFileSize` porque esse nome já existe na API do Windows (`windows.h`) e causaria conflito

```c
int tamanho = GetFileLength("save.dat");
if (tamanho != (int)sizeof(Save)) {
  TraceLog(LOG_WARNING, "save com tamanho inesperado (%d bytes), ignorando", tamanho);
}

DrawText(TextFormat("%.1f KB", GetFileLength("replay.bin") / 1024.0f), 10, 10, 20, GRAY);
```

> O retorno é um `int`, então arquivos maiores que 2 GB não são representados corretamente. Para arquivos grandes, use `stat` diretamente (ver `../../../os/stat.md`)
