**Compressão**

> `raylib.h` — módulo `rcore`

O raylib inclui compressão de dados com o algoritmo DEFLATE (o mesmo usado em arquivos `.zip` e `.png`). Os dados comprimidos ocupam menos espaço em disco e podem ser descomprimidos de volta exatamente iguais (compressão sem perdas)

```c
unsigned char *CompressData(const unsigned char *data, int dataSize, int *compDataSize);
unsigned char *DecompressData(const unsigned char *compData, int compDataSize, int *dataSize);
```

```c
// salvar um mapa grande comprimido
int tamanho_comp = 0;
unsigned char *comp = CompressData((unsigned char *)mapa, sizeof(mapa), &tamanho_comp);
SaveFileData("mapa.bin", comp, tamanho_comp);
TraceLog(LOG_INFO, "%zu bytes -> %d bytes", sizeof(mapa), tamanho_comp);
MemFree(comp);

// carregar e descomprimir
int tamanho_arq = 0;
unsigned char *arq = LoadFileData("mapa.bin", &tamanho_arq);
int tamanho_original = 0;
unsigned char *original = DecompressData(arq, tamanho_arq, &tamanho_original);
if (original != NULL && tamanho_original == sizeof(mapa)) {
  memcpy(mapa, original, sizeof(mapa));
}
MemFree(original);
UnloadFileData(arq);
```

---

**Quanto comprime**

| Dado | Compressão |
|------|------------|
| repetitivo (mapas com muito espaço vazio, texto) | grande, às vezes 10x ou mais |
| já comprimido (PNG, OGG, MP3, ZIP) | quase nenhuma, pode até crescer |
| aleatório | nenhuma |

- DEFLATE funciona encontrando sequências repetidas. Dados sem repetição não diminuem

---

**Memória**

- Os dois buffers devolvidos são alocados pelo raylib e precisam ser liberados com `MemFree`
- O `DecompressData` precisa saber onde os dados terminam: guarde o tamanho comprimido (o `SaveFileData` com o tamanho exato já resolve isso)

> Para guardar dados binários em formato de texto (por exemplo, dentro de um JSON ou para copiar e colar um código de save), o raylib também tem `EncodeDataBase64` e `DecodeDataBase64`, que podem ser aplicados depois da compressão
