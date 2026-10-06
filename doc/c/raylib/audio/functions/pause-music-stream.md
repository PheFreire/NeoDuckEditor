**PauseMusicStream**

> `raylib.h` — módulo `raudio`

O `PauseMusicStream` pausa uma música, guardando a posição atual para continuar depois com `ResumeMusicStream`

```c
void PauseMusicStream(Music music);
```

- `music`: a música

- Não devolve nada
- Enquanto pausada, `IsMusicStreamPlaying` devolve `false` e o `UpdateMusicStream` não avança

```c
if (IsKeyPressed(KEY_P)) {
  pausado = !pausado;
  if (pausado) PauseMusicStream(trilha);
  else ResumeMusicStream(trilha);
}
```

> Continue chamando o `UpdateMusicStream` todo frame mesmo com a música pausada: ele simplesmente não faz nada enquanto a música estiver pausada, e assim o código do loop não precisa mudar
