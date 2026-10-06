**Gamepad**

> `raylib.h` — módulo `rcore`

O raylib lê até 4 gamepads (controles de Xbox, PlayStation, Switch e genéricos) com botões e eixos analógicos. Os botões são nomeados pela **posição** no controle, e não pelo símbolo impresso, para funcionarem igual em controles de fabricantes diferentes

```c
int gp = 0;   // primeiro controle

if (IsGamepadAvailable(gp)) {
  float x = GetGamepadAxisMovement(gp, GAMEPAD_AXIS_LEFT_X);   // -1 (esquerda) a 1 (direita)
  float y = GetGamepadAxisMovement(gp, GAMEPAD_AXIS_LEFT_Y);   // -1 (cima) a 1 (baixo)
  pos.x += x * vel * dt;
  pos.y += y * vel * dt;

  if (IsGamepadButtonPressed(gp, GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) pular();   // A / Cross
}
```

---

**Funções**

| Função | Devolve |
|--------|---------|
| `IsGamepadAvailable(gp)` | `true` se o controle `gp` está conectado |
| `GetGamepadName(gp)` | nome interno do controle |
| `IsGamepadButtonPressed(gp, b)` / `Down` / `Released` / `Up` | estado do botão `b` |
| `GetGamepadAxisCount(gp)` | quantos eixos o controle tem |
| `GetGamepadAxisMovement(gp, eixo)` | valor do eixo, de `-1` a `1` |
| `GetGamepadButtonPressed()` | o último botão apertado em qualquer controle |
| `SetGamepadVibration(gp, esq, dir, duração)` | vibração (quando suportada) |

- `gp` é o índice do controle: `0` a `3`

---

**Botões pela posição**

| Constante | Xbox | PlayStation |
|-----------|------|-------------|
| `GAMEPAD_BUTTON_RIGHT_FACE_DOWN` | A | Cross (✕) |
| `GAMEPAD_BUTTON_RIGHT_FACE_RIGHT` | B | Circle (○) |
| `GAMEPAD_BUTTON_RIGHT_FACE_LEFT` | X | Square (□) |
| `GAMEPAD_BUTTON_RIGHT_FACE_UP` | Y | Triangle (△) |
| `GAMEPAD_BUTTON_LEFT_FACE_*` | D-pad | D-pad |
| `GAMEPAD_BUTTON_LEFT_TRIGGER_1` / `RIGHT_TRIGGER_1` | LB / RB | L1 / R1 |
| `GAMEPAD_BUTTON_LEFT_TRIGGER_2` / `RIGHT_TRIGGER_2` | LT / RT | L2 / R2 |
| `GAMEPAD_BUTTON_MIDDLE_LEFT` / `MIDDLE_RIGHT` | View / Menu | Select / Start |
| `GAMEPAD_BUTTON_LEFT_THUMB` / `RIGHT_THUMB` | apertar o analógico | L3 / R3 |

---

**Eixos**

| Constante | Valor |
|-----------|-------|
| `GAMEPAD_AXIS_LEFT_X` / `LEFT_Y` | analógico esquerdo, de `-1` a `1` |
| `GAMEPAD_AXIS_RIGHT_X` / `RIGHT_Y` | analógico direito, de `-1` a `1` |
| `GAMEPAD_AXIS_LEFT_TRIGGER` / `RIGHT_TRIGGER` | pressão dos gatilhos, de `-1` (solto) a `1` (apertado) |

- No eixo `Y` dos analógicos, `-1` é para **cima**, seguindo o eixo da tela

---

**Zona morta**

Analógicos raramente voltam exatamente para `0`: um controle parado devolve valores como `0.03`, fazendo o personagem andar sozinho. Ignore valores pequenos:

```c
float aplicar_zona_morta(float v) {
  return fabsf(v) < 0.15f ? 0.0f : v;
}
float x = aplicar_zona_morta(GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X));
```

> O raylib usa um banco de mapeamentos (SDL_GameControllerDB, via GLFW) para traduzir os botões de cada modelo para essas constantes. Um controle desconhecido pode ter botões trocados, e mapeamentos extras podem ser carregados com `SetGamepadMappings`
