**WindowShouldClose**

> `raylib.h` — módulo `rcore`

O `WindowShouldClose` informa se o usuário pediu para fechar o programa, clicando no botão de fechar da janela ou apertando a tecla de saída (`Esc` por padrão). É a condição usada no game loop

```c
bool WindowShouldClose(void);
```

- Devolve `true` se o botão de fechar foi clicado ou se a tecla de saída foi pressionada, e `false` caso contrário
- **Não fecha** nada: só informa. O programa decide se sai do laço

```c
while (!WindowShouldClose()) {
  /* atualizar e desenhar */
}
CloseWindow();
```

---

**Pedindo confirmação antes de sair**

Como a função só informa o pedido, o programa pode interceptá-lo:

```c
SetExitKey(KEY_NULL);   // Esc deixa de fechar o programa
bool confirmando = false;
bool sair = false;

while (!sair) {
  if (WindowShouldClose() || IsKeyPressed(KEY_ESCAPE)) {
    confirmando = true;
  }
  if (confirmando) {
    if (IsKeyPressed(KEY_Y)) sair = true;
    if (IsKeyPressed(KEY_N)) confirmando = false;
  }

  BeginDrawing();
  ClearBackground(RAYWHITE);
  if (confirmando) DrawText("Sair? (Y/N)", 300, 200, 30, DARKGRAY);
  EndDrawing();
}
CloseWindow();
```

- `SetExitKey(KEY_NULL)` desativa a tecla de saída, deixando só o botão da janela ativar o `WindowShouldClose` (ver `../../input/functions/set-exit-key.md`)

---

**Armadilhas**

- O estado é atualizado no `EndDrawing`, quando os eventos da janela são processados. Um laço que não chama `EndDrawing` nunca vê o pedido de fechar
- Com `Esc` como tecla de saída, um jogo que usa `Esc` para abrir o menu fecha em vez de abrir o menu. Troque a tecla de saída com `SetExitKey`

> No navegador (build para web), o programa não controla o laço e o `WindowShouldClose` nunca devolve `true`. Nessa plataforma o raylib usa `emscripten_set_main_loop`, e o código precisa ser organizado com uma função que desenha um frame por chamada
