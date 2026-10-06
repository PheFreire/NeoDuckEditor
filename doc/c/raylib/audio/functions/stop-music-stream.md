**StopMusicStream**

> `raylib.h` — módulo `raudio`

O `StopMusicStream` para uma música e volta a posição para o início

```c
void StopMusicStream(Music music);
```

- `music`: a música

- Não devolve nada
- O próximo `PlayMusicStream` começa do início

```c
// fim de jogo: para a música da fase e toca a de game over
StopMusicStream(musica_fase);
PlayMusicStream(musica_game_over);
```

> Uma música parada continua carregada, com o arquivo aberto. Se ela não for mais tocar, libere com `UnloadMusicStream` (ver `unload-music-stream.md`)
