**IsWindowMinimized**

> `raylib.h` — módulo `rcore`

O `IsWindowMinimized` verifica se a janela está minimizada (iconificada), seja pelo usuário, clicando no botão de minimizar, seja pelo programa, com `MinimizeWindow`

```c
bool IsWindowMinimized(void);
```

- Devolve `true` se a janela está minimizada, e `false` caso contrário

```c
while (!WindowShouldClose()) {
  if (IsWindowMinimized()) {
    PauseMusicStream(musica);   // pausa enquanto ninguém está vendo
  } else {
    ResumeMusicStream(musica);
    UpdateMusicStream(musica);
  }

  BeginDrawing();
  /* ... */
  EndDrawing();
}
```

---

**O loop pausa quando a janela é minimizada**

- Por padrão, o raylib **para de rodar o game loop** enquanto a janela está minimizada: o `EndDrawing` espera até ela ser restaurada. O jogo inteiro congela, inclusive a lógica e o áudio que depende do `UpdateMusicStream`
- Para continuar rodando minimizado (um servidor, uma simulação, um download), use a flag `FLAG_WINDOW_ALWAYS_RUN`

```c
SetConfigFlags(FLAG_WINDOW_ALWAYS_RUN);
InitWindow(800, 450, "simulação");
```

> Ao voltar de um longo tempo minimizado, o primeiro `GetFrameTime` pode ser muito grande. Limitar o delta time (`if (dt > 0.1f) dt = 0.1f;`) evita que objetos atravessem paredes nesse frame (ver `../../concepts/delta-time.md`)
