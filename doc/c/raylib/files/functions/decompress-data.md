**DecompressData**

> `raylib.h` — módulo `rcore`

O `DecompressData` reverte o `CompressData`: recebe bytes comprimidos com DEFLATE e devolve os dados originais, exatamente iguais

```c
unsigned char *DecompressData(const unsigned char *compData, int compDataSize, int *dataSize);
```

- `compData`: os bytes comprimidos
- `compDataSize`: quantos bytes comprimidos
- `dataSize`: ponteiro onde é escrito o tamanho dos dados descomprimidos

- Devolve os dados originais, alocados pelo raylib, ou `NULL` se os dados de entrada estiverem corrompidos
- O resultado precisa ser liberado com `MemFree`

```c
int tam_arquivo = 0;
unsigned char *arquivo = LoadFileData("mapa.bin", &tam_arquivo);

int tam_mapa = 0;
unsigned char *mapa = DecompressData(arquivo, tam_arquivo, &tam_mapa);
UnloadFileData(arquivo);

if (mapa != NULL && tam_mapa == 256 * 256) {
  usar_mapa(mapa);
}
MemFree(mapa);
```

> Confira sempre o tamanho devolvido antes de copiar os dados para uma struct ou array de tamanho fixo: um arquivo corrompido ou de outra versão pode descomprimir para um tamanho diferente do esperado
