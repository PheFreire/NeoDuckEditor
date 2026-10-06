**UpdateAudioStream**

> `raylib.h` — módulo `raudio`

O `UpdateAudioStream` envia novas amostras de áudio para um audio stream, preenchendo um dos buffers que o mixer já consumiu

```c
void UpdateAudioStream(AudioStream stream, const void *data, int frameCount);
```

- `stream`: o stream
- `data`: as amostras, no formato do stream (`short` para 16 bits, `float` para 32 bits), intercaladas por canal em estéreo
- `frameCount`: quantos frames enviar (um frame = uma amostra por canal)

- Não devolve nada
- Só deve ser chamado quando há um buffer livre: confira com `IsAudioStreamProcessed`
- `frameCount` não pode passar do tamanho de um buffer do stream (definido por `SetAudioStreamBufferSizeDefault` antes do `LoadAudioStream`). O excesso é descartado com um aviso no log

```c
// ruído branco em estéreo, 16 bits
short buffer[FRAMES * 2];   // 2 canais: esquerda, direita, esquerda, direita...

if (IsAudioStreamProcessed(s)) {
  for (int i = 0; i < FRAMES; i++) {
    short v = (short)GetRandomValue(-8000, 8000);
    buffer[i * 2]     = v;   // esquerda
    buffer[i * 2 + 1] = v;   // direita
  }
  UpdateAudioStream(s, buffer, FRAMES);   // FRAMES frames = FRAMES * 2 amostras
}
```

> Se o programa não enviar dados a tempo (o game loop travou), o mixer fica sem amostras e o som falha com estalos. Buffers maiores toleram travadas mais longas, ao custo de mais atraso entre gerar o som e ouvi-lo (ver `../audio-stream.md`)
