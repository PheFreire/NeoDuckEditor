**LoadAudioStream**

> `raylib.h` — módulo `raudio`

O `LoadAudioStream` cria um canal de áudio vazio, que toca as amostras fornecidas pelo próprio programa. É a base para sintetizar som, emular hardware de áudio ou tocar áudio de uma fonte própria

```c
AudioStream LoadAudioStream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels);
```

- `sampleRate`: amostras por segundo (`44100` ou `48000` são os mais comuns)
- `sampleSize`: bits por amostra: `8`, `16` (`short`) ou `32` (`float`)
- `channels`: `1` para mono, `2` para estéreo

- Devolve o `AudioStream` criado
- Precisa do `InitAudioDevice` antes
- O tamanho dos buffers internos é definido pelo `SetAudioStreamBufferSizeDefault`, que deve ser chamado **antes**

```c
SetAudioStreamBufferSizeDefault(4096);              // 4096 frames por envio
AudioStream synth = LoadAudioStream(44100, 32, 1);  // float, mono
PlayAudioStream(synth);
```

> O formato escolhido define o tipo do buffer que o programa envia depois: `16` bits espera um array de `short`, `32` bits um array de `float` (de `-1.0` a `1.0`). Ver o exemplo completo em `../audio-stream.md`
