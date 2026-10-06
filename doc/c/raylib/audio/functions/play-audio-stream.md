**PlayAudioStream**

> `raylib.h` — módulo `raudio`

O `PlayAudioStream` começa a reprodução de um audio stream. A partir daí, o mixer consome as amostras dos buffers do stream, que precisam ser reabastecidos pelo programa

```c
void PlayAudioStream(AudioStream stream);
```

- `stream`: o stream

- Não devolve nada
- Se os buffers estiverem vazios, o stream toca silêncio até o programa enviar amostras com `UpdateAudioStream` (ou o callback fornecer)

```c
AudioStream s = LoadAudioStream(44100, 16, 1);
PlayAudioStream(s);

while (!WindowShouldClose()) {
  if (IsAudioStreamProcessed(s)) {
    gerar_amostras(buffer, FRAMES);
    UpdateAudioStream(s, buffer, FRAMES);
  }
}
```

> Também existem `PauseAudioStream`, `ResumeAudioStream` e `IsAudioStreamPlaying`, com o mesmo comportamento das funções equivalentes de `Sound` e `Music`
