**UnloadAudioStream**

> `raylib.h` — módulo `raudio`

O `UnloadAudioStream` para um audio stream e libera os buffers internos dele

```c
void UnloadAudioStream(AudioStream stream);
```

- `stream`: o stream a liberar

- Não devolve nada
- Deve ser chamado antes do `CloseAudioDevice`

```c
AudioStream s = LoadAudioStream(44100, 16, 2);
/* ... */
UnloadAudioStream(s);
CloseAudioDevice();
```

> Se o stream usa um callback (`SetAudioStreamCallback`), a função de callback pode estar rodando na thread de áudio. O `UnloadAudioStream` cuida da sincronização, mas os dados que o callback lê devem continuar válidos até a chamada terminar
