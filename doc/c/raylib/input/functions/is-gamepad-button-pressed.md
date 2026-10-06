**IsGamepadButtonPressed**

> `raylib.h` — módulo `rcore`

O `IsGamepadButtonPressed` verifica se um botão de um gamepad foi apertado **neste frame**. Devolve `true` uma vez por aperto, e é usado para ações únicas: pular, confirmar no menu, atirar

```c
bool IsGamepadButtonPressed(int gamepad, int button);
```

- `gamepad`: índice do controle, de `0` a `3`
- `button`: o botão, como uma constante `GAMEPAD_BUTTON_*`

- Devolve `true` no frame em que o botão foi apertado, e `false` nos outros

```c
int gp = 0;
if (IsGamepadAvailable(gp)) {
  if (IsGamepadButtonPressed(gp, GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) pular();       // A / Cross
  if (IsGamepadButtonPressed(gp, GAMEPAD_BUTTON_MIDDLE_RIGHT))    abrir_menu();  // Start / Menu
}
```

> Os botões são nomeados pela posição no controle, e não pelo símbolo: `GAMEPAD_BUTTON_RIGHT_FACE_DOWN` é o A no Xbox e o ✕ no PlayStation. A tabela completa está em `../gamepad.md`
