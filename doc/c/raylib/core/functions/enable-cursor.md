**EnableCursor**

> `raylib.h` — módulo `rcore`

O `EnableCursor` destrava e mostra o cursor depois de um `DisableCursor`, devolvendo o mouse ao comportamento normal: visível e livre para sair da janela

```c
void EnableCursor(void);
```

- Não recebe parâmetros e não devolve nada
- Desfaz o `DisableCursor`: o cursor volta a aparecer e a ter uma posição real
- O cursor é recolocado no centro da janela

```c
bool pausado = false;
DisableCursor();   // jogo começa com o mouse controlando a câmera

while (!WindowShouldClose()) {
  if (IsKeyPressed(KEY_P)) {
    pausado = !pausado;
    if (pausado) EnableCursor();   // menu de pausa precisa do ponteiro
    else DisableCursor();
  }
  if (!pausado) {
    UpdateCamera(&camera, CAMERA_FIRST_PERSON);
  }
  /* ... */
}
```

> Sempre chame o `EnableCursor` ao abrir menus ou mostrar diálogos: com o cursor desabilitado, o usuário não consegue clicar em nada, e nem fechar a janela pelo botão sem sair do jogo primeiro
