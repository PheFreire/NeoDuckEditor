**StopAudioStream**

> `raylib.h` — módulo `raudio`

O `StopAudioStream` para a reprodução de um audio stream

```c
void StopAudioStream(AudioStream stream);
```

- `stream`: o stream

- Não devolve nada
- Os dados que estavam nos buffers são descartados
- Para voltar a tocar, chame `PlayAudioStream` e volte a enviar amostras

```c
// sintetizador: o som só existe enquanto a tecla está apertada
if (IsKeyPressed(KEY_A))  PlayAudioStream(synth);
if (IsKeyReleased(KEY_A)) StopAudioStream(synth);
```

> Parar e recomeçar um stream de forma brusca pode gerar um estalo, pois a onda é cortada no meio. Sintetizadores costumam reduzir o volume das amostras gradualmente (envelope de release) antes de parar
