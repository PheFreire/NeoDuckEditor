**SetExitKey**

> `raylib.h` — módulo `rcore`

O `SetExitKey` define qual tecla faz o `WindowShouldClose` devolver `true`. Por padrão é o `Esc`, o que fecha o programa ao apertar essa tecla

```c
void SetExitKey(int key);
```

- `key`: a nova tecla de saída, como uma constante `KEY_*`. `KEY_NULL` (`0`) desativa a tecla de saída

- Não devolve nada
- O botão de fechar da janela continua funcionando independente da tecla

```c
InitWindow(800, 450, "jogo");
SetExitKey(KEY_NULL);   // Esc não fecha mais o jogo

while (!WindowShouldClose()) {
  if (IsKeyPressed(KEY_ESCAPE)) {
    menu_aberto = !menu_aberto;   // Esc agora abre o menu de pausa
  }
  /* ... */
}
```

> Quase todo jogo usa o `Esc` para o menu de pausa. Sem o `SetExitKey(KEY_NULL)`, apertar `Esc` fecha o jogo inteiro em vez de abrir o menu. Se o programa precisar de uma forma rápida de sair durante o desenvolvimento, use outra tecla, como `SetExitKey(KEY_F12)`
