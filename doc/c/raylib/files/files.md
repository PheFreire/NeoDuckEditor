**files**

> `raylib.h` — módulo `rcore`

O raylib tem funções próprias para arquivos: ler e salvar arquivos inteiros de uma vez (bytes ou texto), consultar caminhos e extensões, verificar se arquivos e pastas existem, receber arquivos arrastados para a janela e comprimir dados. Elas simplificam as tarefas mais comuns de um jogo, como salvar o progresso e carregar configurações, sem precisar do `fopen`/`fread`

```c
// salvar e carregar o progresso
typedef struct { int fase; int pontos; } Save;

Save s = { 3, 1200 };
SaveFileData("save.dat", &s, sizeof(s));

int tamanho = 0;
unsigned char *dados = LoadFileData("save.dat", &tamanho);
if (dados != NULL && tamanho == sizeof(Save)) {
  memcpy(&s, dados, sizeof(Save));
}
UnloadFileData(dados);
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| ler e salvar bytes | `file-data.md` |
| ler e salvar texto | `file-text.md` |
| caminhos, nomes, extensões e diretórios | `paths.md` |
| arquivos arrastados para a janela | `dropped-files.md` |
| comprimir e descomprimir dados | `compression.md` |

- Cada função tem sua nota em `functions/`

---

**Funções**

| Grupo | Funções |
|-------|---------|
| dados | `LoadFileData`, `UnloadFileData`, `SaveFileData` |
| texto | `LoadFileText`, `UnloadFileText`, `SaveFileText` |
| consulta | `FileExists`, `DirectoryExists`, `IsFileExtension`, `GetFileLength` |
| caminhos | `GetFileExtension`, `GetFileName`, `GetDirectoryPath`, `ChangeDirectory`, `GetWorkingDirectory`, `GetApplicationDirectory` |
| arrastar e soltar | `IsFileDropped`, `LoadDroppedFiles`, `UnloadDroppedFiles` |
| compressão | `CompressData`, `DecompressData` |

---

**Quem libera a memória**

| Função | Memória devolvida | Liberar com |
|--------|-------------------|-------------|
| `LoadFileData` | bytes alocados | `UnloadFileData` |
| `LoadFileText` | string alocada | `UnloadFileText` |
| `LoadDroppedFiles` | lista de caminhos | `UnloadDroppedFiles` |
| `CompressData` / `DecompressData` | bytes alocados | `MemFree` |
| `GetFileName`, `GetFileExtension` | ponteiro **dentro** da string passada | nada |
| `GetDirectoryPath`, `GetWorkingDirectory` | buffer **estático** do raylib | nada (copie se for guardar) |

> Diferente das funções de imagem e textura, as funções de arquivo não precisam da janela: podem ser usadas antes do `InitWindow`, por exemplo para ler um arquivo de configuração com o tamanho da janela
