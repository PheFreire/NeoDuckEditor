**SaveFileData**

> `raylib.h` — módulo `rcore`

O `SaveFileData` escreve um bloco de bytes em um arquivo, substituindo o conteúdo anterior

```c
bool SaveFileData(const char *fileName, void *data, int dataSize);
```

- `fileName`: o caminho do arquivo
- `data`: ponteiro para os bytes (qualquer tipo: struct, array, buffer)
- `dataSize`: quantos bytes escrever

- Devolve `true` se o arquivo foi salvo, e `false` em caso de erro (pasta inexistente, sem permissão, disco cheio)
- Cria o arquivo se não existir e sobrescreve se existir
- Não cria pastas: a pasta do caminho precisa existir

```c
typedef struct { int fase; int moedas; float tempo; } Save;
Save s = { fase, moedas, tempo };

if (!SaveFileData("saves/slot1.sav", &s, sizeof(s))) {
  if (!DirectoryExists("saves")) MakeDirectory("saves");   // cria a pasta e tenta de novo
  SaveFileData("saves/slot1.sav", &s, sizeof(s));
}
```

> Se o programa travar no meio da escrita, o arquivo pode ficar corrompido. Para saves importantes, uma técnica comum é salvar em um arquivo temporário e depois renomear para o nome final, o que substitui o arquivo de uma vez (ver `../../../os/rename.md`)
