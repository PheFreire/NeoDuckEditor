**input**

> `raylib.h` — módulo `rcore`

O input do raylib lê o que o usuário faz com o teclado, o mouse, o gamepad e a tela de toque. Em vez de eventos com callbacks, o raylib guarda o **estado** de cada dispositivo a cada frame, e o programa pergunta, quando quiser, se uma tecla está pressionada ou onde o mouse está

```c
while (!WindowShouldClose()) {
  if (IsKeyPressed(KEY_SPACE))                 pular();                 // teclado
  if (IsMouseButtonDown(MOUSE_BUTTON_LEFT))    atirar(GetMousePosition()); // mouse
  if (IsGamepadAvailable(0) &&
      IsGamepadButtonPressed(0, GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) pular(); // gamepad
  /* ... */
}
```

---

**Conteúdo**

| Dispositivo | Ver |
|-------------|-----|
| teclado | `keyboard.md` |
| mouse | `mouse.md` |
| gamepad | `gamepad.md` |
| tela de toque | `touch.md` |
| gestos (tap, swipe, pinch) | `gestures.md` |

- Cada função tem sua nota em `functions/`

---

**Os quatro estados de um botão**

Toda tecla e todo botão (teclado, mouse, gamepad) tem as mesmas quatro consultas:

```text
frame:       1     2     3     4     5     6
físico:      solto solto apert apert apert solto
                         ▲                 ▲
Pressed:     -     -     true  -     -     -        só no frame em que foi apertado
Down:        -     -     true  true  true  -        enquanto está apertado
Released:    -     -     -     -     -     true     só no frame em que foi solto
Up:          true  true  -     -     -     true     enquanto está solto
```

| Função | Verdadeiro quando | Uso |
|--------|-------------------|-----|
| `Is...Pressed` | apertado **neste** frame | ações únicas: pular, atirar, abrir menu |
| `Is...Down` | está apertado | ações contínuas: andar, acelerar, mirar |
| `Is...Released` | solto **neste** frame | fim de uma ação: soltar a corda do arco |
| `Is...Up` | está solto | o contrário de `Down` |

---

**Como o input é atualizado**

```text
EndDrawing()
  │  PollInputEvents(): lê os eventos do sistema e
  │  guarda o estado atual e o do frame anterior
  ▼
próximo frame
  │  IsKeyPressed(k) = (atual[k] == apertado) && (anterior[k] == solto)
  │  IsKeyDown(k)    = (atual[k] == apertado)
  ▼
```

- O estado é atualizado **uma vez por frame**, no `EndDrawing`. Todas as consultas dentro do mesmo frame veem o mesmo estado
- Por isso o `Is...Pressed` é verdadeiro durante o frame inteiro, e pode ser consultado várias vezes sem "consumir" o evento

> O raylib não usa callbacks de input: não existe "ao apertar a tecla, chame esta função". O programa consulta o estado no próprio game loop, normalmente na fase de atualização, antes de desenhar (ver `../core/application-loop.md`)
