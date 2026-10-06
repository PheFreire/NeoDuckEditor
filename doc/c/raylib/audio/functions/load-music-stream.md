**LoadMusicStream**

> `raylib.h` — módulo `raudio`

O `LoadMusicStream` abre um arquivo de áudio para tocar por streaming: o arquivo não é decodificado de uma vez, e sim em pequenos pedaços durante a reprodução. É a forma de carregar músicas e sons longos

```c
Music LoadMusicStream(const char *fileName);
```

- `fileName`: o arquivo (OGG, MP3, WAV, QOA, XM, MOD...)

- Devolve a `Music`, com `looping = true` por padrão
- Precisa do `InitAudioDevice` antes
- O arquivo fica aberto até o `UnloadMusicStream`
- Se falhar, escreve um aviso no log. Confira com `IsMusicValid`

```c
Music menu = LoadMusicStream("musica/menu.ogg");
PlayMusicStream(menu);

while (!WindowShouldClose()) {
  UpdateMusicStream(menu);   // obrigatório todo frame
  /* ... */
}

UnloadMusicStream(menu);
```

> Carregar é rápido, pois quase nada é decodificado no início. Em contrapartida, a música depende do `UpdateMusicStream` a cada frame para continuar tocando (ver `update-music-stream.md` e `../music.md`)
