**LoadFileData**

> `raylib.h` — módulo `rcore`

O `LoadFileData` lê um arquivo inteiro para a memória como um array de bytes, sem interpretar o conteúdo

```c
unsigned char *LoadFileData(const char *fileName, int *dataSize);
```

- `fileName`: o caminho do arquivo
- `dataSize`: ponteiro onde é escrito quantos bytes foram lidos

- Devolve um ponteiro para os bytes, alocados pelo raylib
- Se o arquivo não existir ou não puder ser lido, devolve `NULL`, escreve `0` em `dataSize` e mostra um aviso no log
- Os bytes precisam ser liberados com `UnloadFileData`

```c
int tamanho = 0;
unsigned char *bytes = LoadFileData("nivel.bin", &tamanho);
if (bytes == NULL) {
  return;   // arquivo ausente
}

for (int i = 0; i < tamanho; i++) {
  mapa[i / LARGURA][i % LARGURA] = bytes[i];   // um byte por célula do mapa
}

UnloadFileData(bytes);
```

> O conteúdo não termina com `\0`: use sempre o `dataSize` para saber o tamanho. Para ler texto como uma string, o `LoadFileText` adiciona o `\0` (ver `load-file-text.md` e `../file-data.md`)
