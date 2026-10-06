**DirectoryExists**

> `raylib.h` — módulo `rcore`

O `DirectoryExists` verifica se uma pasta existe no caminho indicado

```c
bool DirectoryExists(const char *dirPath);
```

- `dirPath`: o caminho da pasta

- Devolve `true` se a pasta existe, e `false` caso contrário (inclusive se o caminho for de um arquivo)

```c
if (!DirectoryExists("saves")) {
  MakeDirectory("saves");   // cria a pasta antes de salvar
}
SaveFileData("saves/slot1.sav", &save, sizeof(save));

if (!DirectoryExists("assets")) {
  TraceLog(LOG_FATAL, "pasta assets não encontrada: rode o jogo a partir da pasta dele");
}
```

> A causa mais comum de "pasta não encontrada" é o diretório de trabalho ser outro, e não a pasta realmente não existir. Usar `ChangeDirectory(GetApplicationDirectory())` no início resolve a maioria dos casos (ver `../paths.md`)
