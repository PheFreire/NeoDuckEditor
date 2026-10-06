**SaveFileText**

> `raylib.h` — módulo `rcore`

O `SaveFileText` escreve uma string em um arquivo de texto, substituindo o conteúdo anterior

```c
bool SaveFileText(const char *fileName, char *text);
```

- `fileName`: o caminho do arquivo
- `text`: a string, terminada em `\0` (o `\0` não é escrito)

- Devolve `true` se salvou, e `false` em caso de erro
- Cria o arquivo se não existir e sobrescreve se existir

```c
char linha[128];
snprintf(linha, sizeof(linha), "recorde=%d\nnome=%s\n", recorde, nome_jogador);
SaveFileText("recorde.txt", linha);
```

> Formatos de texto são fáceis de ler, editar à mão e compatíveis entre sistemas. Para muitos dados, ou dados que não devem ser editados pelo jogador, o `SaveFileData` com um formato binário ocupa menos espaço (ver `../file-text.md`)
