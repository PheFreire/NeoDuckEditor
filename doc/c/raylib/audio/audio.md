**audio**

> `raylib.h` — módulo `raudio`

O módulo de áudio toca efeitos sonoros, músicas e áudio gerado pelo programa. Ele é independente da janela: tem o seu próprio dispositivo, iniciado com `InitAudioDevice`, e uma thread interna que mistura os sons e os envia para a placa de som

```c
InitWindow(800, 450, "audio");
InitAudioDevice();                              // liga o dispositivo de áudio

Sound pulo  = LoadSound("pulo.wav");            // efeito curto: inteiro na memória
Music trilha = LoadMusicStream("trilha.ogg");   // música longa: lida aos poucos (streaming)
PlayMusicStream(trilha);

while (!WindowShouldClose()) {
  UpdateMusicStream(trilha);                    // obrigatório todo frame para a música continuar
  if (IsKeyPressed(KEY_SPACE)) PlaySound(pulo);
  /* ... */
}

UnloadSound(pulo);
UnloadMusicStream(trilha);
CloseAudioDevice();
CloseWindow();
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| o dispositivo de áudio | `audio-device.md` |
| efeitos sonoros (`Sound`) | `sound.md` |
| músicas (`Music`) | `music.md` |
| áudio gerado pelo programa (`AudioStream`) | `audio-stream.md` |
| volume, pitch e pan | `volume.md` |

- Cada função tem sua nota em `functions/`

---

**Sound, Music e AudioStream**

| Tipo | Onde fica o áudio | Uso | Atualização |
|------|-------------------|-----|-------------|
| `Sound` | inteiro na memória, já decodificado | efeitos curtos: pulo, tiro, clique | automática |
| `Music` | no arquivo, decodificado aos poucos | músicas e ambientes longos | `UpdateMusicStream` todo frame |
| `AudioStream` | gerado pelo programa | sintetizadores, emuladores, áudio procedural | `UpdateAudioStream` ou callback |

```text
Sound:   arquivo ──► decodifica tudo ──► memória ──► mixer
Music:   arquivo ──► decodifica um pedaço ──► buffer ──► mixer
                     ▲ UpdateMusicStream pede o próximo pedaço
Stream:  programa ──► amostras ──► buffer ──► mixer
```

---

**Formatos**

- Na configuração padrão do raylib: WAV, OGG, MP3, QOA, XM e MOD. FLAC existe, mas fica desligado por padrão
- WAV e OGG são os mais usados: WAV para efeitos curtos (sem custo de decodificação), OGG para músicas (arquivo pequeno)

> O áudio roda em uma thread própria, criada pela biblioteca miniaudio usada internamente. As funções do raylib cuidam da sincronização, mas callbacks de áudio (`SetAudioStreamCallback`) rodam nessa outra thread e não devem chamar funções de desenho nem alterar dados do jogo sem cuidado (ver `../../thread/pthread/functions/pthread_mutex_lock.md`)
