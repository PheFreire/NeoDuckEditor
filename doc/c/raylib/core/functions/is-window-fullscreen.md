**IsWindowFullscreen**

> `raylib.h` — módulo `rcore`

O `IsWindowFullscreen` verifica se a janela está em modo fullscreen exclusivo, ativado por `ToggleFullscreen` ou pela flag `FLAG_FULLSCREEN_MODE`

```c
bool IsWindowFullscreen(void);
```

- Devolve `true` se a janela está em fullscreen, e `false` caso contrário
- Não considera o modo "borderless windowed" (`FLAG_BORDERLESS_WINDOWED_MODE`), que é uma janela comum sem borda do tamanho do monitor. Para ele, use `IsWindowState(FLAG_BORDERLESS_WINDOWED_MODE)`

```c
if (IsKeyPressed(KEY_F11)) {
  ToggleFullscreen();
}
DrawText(IsWindowFullscreen() ? "fullscreen" : "janela", 10, 10, 20, DARKGRAY);
```

---

**Salvando a preferência do usuário**

```c
bool fullscreen = IsWindowFullscreen();
salvar_config("fullscreen", fullscreen);   // ao sair

// na próxima execução
if (carregar_config("fullscreen")) {
  SetConfigFlags(FLAG_FULLSCREEN_MODE);
}
InitWindow(1920, 1080, "jogo");
```

> Ver `toggle-fullscreen.md` para a diferença entre fullscreen exclusivo e borderless windowed, e por que a resolução da janela importa ao entrar em fullscreen
