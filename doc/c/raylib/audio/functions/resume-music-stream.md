**ResumeMusicStream**

> `raylib.h` — módulo `raudio`

O `ResumeMusicStream` continua uma música pausada, a partir do ponto em que ela parou

```c
void ResumeMusicStream(Music music);
```

- `music`: a música

- Não devolve nada
- Só tem efeito em uma música pausada com `PauseMusicStream`

```c
// pausar a música quando a janela perde o foco
if (!IsWindowFocused() && IsMusicStreamPlaying(trilha)) {
  PauseMusicStream(trilha);
} else if (IsWindowFocused() && !IsMusicStreamPlaying(trilha)) {
  ResumeMusicStream(trilha);
}
```

> Para recomeçar do início, use `StopMusicStream` seguido de `PlayMusicStream`. Para ir a um ponto específico, o `SeekMusicStream(musica, segundos)` muda a posição sem parar
