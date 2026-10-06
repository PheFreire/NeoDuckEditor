**IsMusicStreamPlaying**

> `raylib.h` — módulo `raudio`

O `IsMusicStreamPlaying` verifica se uma música está tocando neste momento

```c
bool IsMusicStreamPlaying(Music music);
```

- `music`: a música

- Devolve `true` se está tocando, e `false` se está parada, pausada, terminou (sem loop) ou nunca tocou

```c
Music vitoria = LoadMusicStream("vitoria.ogg");
vitoria.looping = false;
PlayMusicStream(vitoria);

while (!WindowShouldClose()) {
  UpdateMusicStream(vitoria);
  if (!IsMusicStreamPlaying(vitoria)) {
    voltar_ao_menu();   // a música de vitória terminou
  }
  /* ... */
}
```

> Com `looping = true` (o padrão), a música nunca termina sozinha, e o `IsMusicStreamPlaying` só fica `false` por pausa ou parada. Para saber a posição atual, use o `GetMusicTimePlayed` (ver `../music.md`)
