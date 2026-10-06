**PlayMusicStream**

> `raylib.h` — módulo `raudio`

O `PlayMusicStream` começa a tocar uma música do início

```c
void PlayMusicStream(Music music);
```

- `music`: a música

- Não devolve nada
- Começa a reprodução. Os pedaços seguintes da música dependem do `UpdateMusicStream` em todo frame
- Se a música já estiver tocando, continua de onde está (não recomeça). Para recomeçar do início, chame `StopMusicStream` antes

```c
Music trilha = LoadMusicStream("trilha.ogg");
PlayMusicStream(trilha);   // uma vez, antes do loop

while (!WindowShouldClose()) {
  UpdateMusicStream(trilha);
  /* ... */
}
```

> O `PlayMusicStream` só inicia a reprodução: chame uma vez, fora do game loop. Quem mantém a música tocando a cada frame é o `UpdateMusicStream` (ver `update-music-stream.md`)
