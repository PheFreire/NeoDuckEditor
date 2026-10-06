**IsGamepadButtonUp**

> `raylib.h` — módulo `rcore`

O `IsGamepadButtonUp` verifica se um botão de um gamepad **não** está apertado. É o contrário exato do `IsGamepadButtonDown`

```c
bool IsGamepadButtonUp(int gamepad, int button);
```

- `gamepad`: índice do controle, de `0` a `3`
- `button`: o botão, como uma constante `GAMEPAD_BUTTON_*`

- Devolve `true` enquanto o botão está solto, e `false` enquanto está apertado

```c
// escudo só cai quando o botão de defesa está solto
if (IsGamepadButtonUp(0, GAMEPAD_BUTTON_LEFT_TRIGGER_1)) {
  escudo_ativo = false;
}
```

> Equivale a `!IsGamepadButtonDown(gamepad, button)`. Existe para manter a mesma API de quatro estados do teclado e do mouse (ver `../input.md`)
