**AudioStream**

> `raylib.h` — módulo `raudio`

Um `AudioStream` é um canal de áudio em que o próprio programa fornece as amostras. Em vez de tocar um arquivo, o programa calcula o som: sintetizadores, emuladores de console, efeitos procedurais, áudio recebido pela rede ou decodificado por uma biblioteca própria

```c
typedef struct AudioStream {
  rAudioBuffer *buffer;          // buffer interno
  rAudioProcessor *processor;    // efeitos aplicados
  unsigned int sampleRate;       // amostras por segundo (ex: 44100)
  unsigned int sampleSize;       // bits por amostra: 8, 16 ou 32 (float)
  unsigned int channels;         // 1 mono, 2 estéreo
} AudioStream;
```

| Função | Faz |
|--------|-----|
| `LoadAudioStream(taxa, bits, canais)` | cria o canal |
| `UnloadAudioStream(s)` | libera |
| `PlayAudioStream(s)` / `StopAudioStream(s)` | começa e para |
| `IsAudioStreamProcessed(s)` | `true` se um buffer foi consumido e precisa de novos dados |
| `UpdateAudioStream(s, dados, frames)` | envia novas amostras |
| `SetAudioStreamCallback(s, funcao)` | em vez de enviar no game loop, a thread de áudio chama a função pedindo dados |

---

**Amostras, frames e canais**

```text
som = uma onda, medida (amostrada) sampleRate vezes por segundo

mono  (1 canal):   [a0][a1][a2][a3]...           1 amostra por frame
estéreo (2):       [E0 D0][E1 D1][E2 D2]...       2 amostras por frame (esquerda, direita)

frameCount = quantos instantes de tempo, e não quantos bytes
bytes = frames x canais x (sampleSize / 8)
```

---

**Gerando uma onda senoidal (nota musical)**

```c
#define TAXA 44100
#define FRAMES 4096

SetAudioStreamBufferSizeDefault(FRAMES);         // buffers do tamanho de cada envio
AudioStream s = LoadAudioStream(TAXA, 16, 1);   // 16 bits, mono
short buffer[FRAMES];
float fase = 0;
float frequencia = 440.0f;   // nota Lá

PlayAudioStream(s);

while (!WindowShouldClose()) {
  if (IsAudioStreamProcessed(s)) {              // o mixer pediu mais dados
    for (int i = 0; i < FRAMES; i++) {
      buffer[i] = (short)(sinf(fase) * 32000);  // amplitude de um short
      fase += 2 * PI * frequencia / TAXA;
      if (fase > 2 * PI) fase -= 2 * PI;
    }
    UpdateAudioStream(s, buffer, FRAMES);
  }
  /* ... */
}

UnloadAudioStream(s);
```

- O `UpdateAudioStream` aceita no máximo o tamanho de um buffer interno do stream. Enviar mais frames gera o aviso `Attempting to write too many frames to buffer` e o excesso é descartado. Por isso o `SetAudioStreamBufferSizeDefault(FRAMES)` vem **antes** do `LoadAudioStream`

---

**Game loop vs callback**

| | `UpdateAudioStream` no loop | `SetAudioStreamCallback` |
|---|---|---|
| Quem chama | o game loop | a thread de áudio |
| Latência | depende do FPS | baixa, sob demanda |
| Risco | travadas no loop causam falhas no som | a função roda em outra thread: cuidado com dados compartilhados |

> `Music` e `Sound` são construídos sobre o `AudioStream`: a diferença é quem fornece as amostras. Com o `AudioStream`, o programa tem controle total, e também a responsabilidade de nunca deixar o buffer esvaziar
