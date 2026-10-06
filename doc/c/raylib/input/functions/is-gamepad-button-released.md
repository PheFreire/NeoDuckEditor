**IsGamepadButtonReleased**

> `raylib.h` — módulo `rcore`

O `IsGamepadButtonReleased` verifica se um botão de um gamepad foi solto **neste frame**. Devolve `true` uma vez, no frame em que o botão deixou de ser apertado

```c
bool IsGamepadButtonReleased(int gamepad, int button);
```

- `gamepad`: índice do controle, de `0` a `3`
- `button`: o botão, como uma constante `GAMEPAD_BUTTON_*`

- Devolve `true` no frame em que o botão foi solto, e `false` nos outros

```c
// segurar para carregar, soltar para disparar
static float carga = 0;
if (IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
  carga += GetFrameTime();
}
if (IsGamepadButtonReleased(0, GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) {
  disparar(carga);
  carga = 0;
}
```

> Se o controle for desconectado com o botão apertado, o evento de soltar não acontece. Zere estados como a `carga` também quando o `IsGamepadAvailable` voltar a `false`
