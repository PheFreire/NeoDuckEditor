**CompressData**

> `raylib.h` — módulo `rcore`

O `CompressData` comprime um bloco de bytes com o algoritmo DEFLATE, devolvendo uma versão menor dos mesmos dados

```c
unsigned char *CompressData(const unsigned char *data, int dataSize, int *compDataSize);
```

- `data`: os bytes a comprimir
- `dataSize`: quantos bytes
- `compDataSize`: ponteiro onde é escrito o tamanho do resultado

- Devolve os bytes comprimidos, alocados pelo raylib, ou `NULL` em caso de erro
- O resultado precisa ser liberado com `MemFree`

```c
// mapa de 256x256 tiles, com muitos tiles vazios repetidos
unsigned char mapa[256 * 256];
int tamanho = 0;
unsigned char *comp = CompressData(mapa, sizeof(mapa), &tamanho);

SaveFileData("mapa.bin", comp, tamanho);
TraceLog(LOG_INFO, "65536 bytes viraram %d bytes", tamanho);
MemFree(comp);
```

> Dados repetitivos comprimem muito (um texto com 82 letras `a` vira 16 bytes). Arquivos que já são comprimidos, como PNG, OGG e MP3, praticamente não diminuem (ver `../compression.md`)
