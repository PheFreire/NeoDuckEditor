**Music**

> `raylib.h` — módulo `raudio`

Uma `Music` é um áudio longo tocado por **streaming**: em vez de decodificar o arquivo inteiro na memória, o raylib decodifica pequenos pedaços conforme a música toca. É o tipo certo para trilhas sonoras, sons ambientes e qualquer áudio com mais de alguns segundos

```c
typedef struct Music {
  AudioStream stream;        // canal de áudio
  unsigned int frameCount;   // duração total, em frames
  bool looping;              // repete ao terminar (true por padrão)
  int ctxType;               // tipo do arquivo (OGG, MP3, ...)
  void *ctxData;             // decodificador
} Music;
```

| Função | Faz |
|--------|-----|
| `LoadMusicStream(arquivo)` | abre o arquivo e prepara o decodificador |
| `UnloadMusicStream(m)` | fecha e libera |
| `PlayMusicStream(m)` | começa a tocar |
| `UpdateMusicStream(m)` | decodifica e envia o próximo pedaço (**todo frame**) |
| `StopMusicStream(m)` | para e volta ao início |
| `PauseMusicStream(m)` / `ResumeMusicStream(m)` | pausa e continua |
| `IsMusicStreamPlaying(m)` | `true` se está tocando |
| `SeekMusicStream(m, segundos)` | pula para uma posição |
| `GetMusicTimeLength(m)` / `GetMusicTimePlayed(m)` | duração e posição atual, em segundos |
| `SetMusicVolume` / `SetMusicPitch` / `SetMusicPan` | volume, tom e posição estéreo |

```c
Music trilha = LoadMusicStream("fase1.ogg");
PlayMusicStream(trilha);

while (!WindowShouldClose()) {
  UpdateMusicStream(trilha);   // sem isso, a música toca só o primeiro pedaço e para

  float progresso = GetMusicTimePlayed(trilha) / GetMusicTimeLength(trilha);
  DrawRectangle(10, 430, (int)(780 * progresso), 10, SKYBLUE);
  /* ... */
}

UnloadMusicStream(trilha);
```

---

**Por que o UpdateMusicStream é necessário**

```text
arquivo .ogg (3 min)
  │ UpdateMusicStream: decodifica o próximo pedaço quando o buffer esvazia
  ▼
buffer de áudio (alguns décimos de segundo)
  │ thread de áudio consome
  ▼
placa de som
```

- O buffer guarda só uma fração de segundo de áudio. O `UpdateMusicStream` verifica se ele precisa de mais dados e decodifica o próximo pedaço
- Se o game loop parar (um carregamento demorado, a janela minimizada sem `FLAG_WINDOW_ALWAYS_RUN`), o buffer esvazia e a música trava ou repete o último pedaço

---

**Repetição**

```c
Music efeito = LoadMusicStream("chuva.ogg");
efeito.looping = true;    // padrão: volta ao início ao terminar
Music final = LoadMusicStream("vitoria.ogg");
final.looping = false;    // toca uma vez
```

> Cada `Music` mantém o arquivo aberto e um decodificador ativo. Para tocar uma música diferente, chame `StopMusicStream` e `UnloadMusicStream` na antiga antes de carregar a nova
