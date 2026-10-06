**Sound**

> `raylib.h` — módulo `raudio`

Um `Sound` é um efeito sonoro carregado inteiro na memória, já decodificado e pronto para tocar instantaneamente. É o tipo certo para sons curtos e repetidos: passos, tiros, pulos, cliques, explosões

```c
typedef struct Sound {
  AudioStream stream;        // canal de áudio interno
  unsigned int frameCount;   // duração, em frames de áudio
} Sound;
```

| Função | Faz |
|--------|-----|
| `LoadSound(arquivo)` | carrega e decodifica o arquivo inteiro |
| `UnloadSound(som)` | libera a memória |
| `PlaySound(som)` | toca desde o início |
| `StopSound(som)` | para e volta ao início |
| `PauseSound(som)` / `ResumeSound(som)` | pausa e continua de onde parou |
| `IsSoundPlaying(som)` | `true` se está tocando |
| `SetSoundVolume(som, v)` / `SetSoundPitch(som, p)` / `SetSoundPan(som, p)` | volume, tom e posição estéreo |
| `LoadSoundAlias(som)` | outra "voz" do mesmo som, sem duplicar os dados |

```c
Sound tiro = LoadSound("tiro.wav");

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
  SetSoundPitch(tiro, 0.9f + GetRandomValue(0, 20) / 100.0f);   // variação para não soar repetitivo
  PlaySound(tiro);
}
```

---

**Um Sound toca uma vez por vez**

```text
PlaySound(tiro)   ▶ tocando...
PlaySound(tiro)   ▶ recomeça do início (o primeiro é cortado)
```

- Chamar `PlaySound` em um som que já está tocando **reinicia** o som, em vez de tocar duas cópias sobrepostas
- Para vários tiros ao mesmo tempo, crie aliases com `LoadSoundAlias`: cada alias é uma voz independente que compartilha os mesmos dados de áudio

```c
#define VOZES 8
Sound tiro = LoadSound("tiro.wav");
Sound vozes[VOZES];
for (int i = 0; i < VOZES; i++) vozes[i] = LoadSoundAlias(tiro);
int proxima = 0;

if (atirou) {
  PlaySound(vozes[proxima]);
  proxima = (proxima + 1) % VOZES;   // usa as vozes em rodízio
}

for (int i = 0; i < VOZES; i++) UnloadSoundAlias(vozes[i]);
UnloadSound(tiro);
```

---

**Memória**

```text
WAV de 1 s, 44100 Hz, 16 bits, estéreo = 44100 x 2 bytes x 2 canais ≈ 172 KB
música de 3 min como Sound            ≈ 31 MB
```

- Como o `Sound` fica todo decodificado na memória, sons longos ocupam muito espaço. Para músicas, use `Music` (ver `music.md`)

> Um `Sound` toca até o fim sem nenhuma chamada no game loop: o mixer cuida dele na thread de áudio. Já uma `Music` precisa de `UpdateMusicStream` todo frame, uma diferença que é fonte comum de músicas que param depois de alguns segundos
