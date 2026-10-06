**IsGamepadButtonDown**

> `raylib.h` — módulo `rcore`

O `IsGamepadButtonDown` verifica se um botão de um gamepad está apertado agora. Devolve `true` em todos os frames enquanto o botão está segurado, e é usado para ações contínuas: correr, acelerar, mirar

```c
bool IsGamepadButtonDown(int gamepad, int button);
```

- `gamepad`: índice do controle, de `0` a `3`
- `button`: o botão, como uma constante `GAMEPAD_BUTTON_*`

- Devolve `true` enquanto o botão está apertado, e `false` enquanto está solto

```c
float vel = 150.0f;
if (IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) {   // X / Square
  vel = 300.0f;   // corre enquanto segura
}

// D-pad como direcional digital
if (IsGamepadButtonDown(0, GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) pos.x += vel * dt;
if (IsGamepadButtonDown(0, GAMEPAD_BUTTON_LEFT_FACE_LEFT))  pos.x -= vel * dt;
```

> Os gatilhos analógicos (`L2`/`R2`, `LT`/`RT`) existem tanto como botão (`GAMEPAD_BUTTON_LEFT_TRIGGER_2`) quanto como eixo (`GAMEPAD_AXIS_LEFT_TRIGGER`). Use o eixo quando a pressão importa, como em um acelerador (ver `get-gamepad-axis-movement.md`)
