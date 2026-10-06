**LoadSound**

> `raylib.h` — módulo `raudio`

O `LoadSound` carrega um arquivo de áudio inteiro na memória, já decodificado, pronto para tocar sem atraso. É usado para efeitos sonoros curtos

```c
Sound LoadSound(const char *fileName);
```

- `fileName`: o arquivo de áudio (WAV, OGG, MP3, QOA...)

- Devolve o `Sound` carregado
- Precisa do `InitAudioDevice` antes
- Se falhar, escreve um aviso no log. Confira com `IsSoundValid`

```c
InitAudioDevice();

Sound pulo  = LoadSound("sfx/pulo.wav");
Sound moeda = LoadSound("sfx/moeda.wav");

if (IsKeyPressed(KEY_SPACE)) PlaySound(pulo);
```

---

**Sound ou Music?**

- `LoadSound` decodifica o arquivo inteiro: um OGG de 3 minutos vira cerca de 30 MB na memória, e o carregamento demora
- Para áudio com mais de alguns segundos, use `LoadMusicStream`, que lê aos poucos (ver `../music.md`)

> Todo `Sound` carregado precisa de um `UnloadSound` antes do `CloseAudioDevice`. Para tocar o mesmo efeito várias vezes ao mesmo tempo, crie aliases com `LoadSoundAlias` em vez de carregar o arquivo de novo (ver `../sound.md`)
