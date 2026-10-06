**GetGamepadAxisMovement**

> `raylib.h` — módulo `rcore`

O `GetGamepadAxisMovement` devolve o valor atual de um eixo analógico do gamepad: a inclinação de um analógico ou a pressão de um gatilho. É a forma de ler movimento proporcional, em que inclinar pouco anda devagar e inclinar tudo anda rápido

```c
float GetGamepadAxisMovement(int gamepad, int axis);
```

- `gamepad`: índice do controle, de `0` a `3`
- `axis`: o eixo, como uma constante `GAMEPAD_AXIS_*`

- Analógicos (`GAMEPAD_AXIS_LEFT_X`, `LEFT_Y`, `RIGHT_X`, `RIGHT_Y`): devolvem de `-1.0` a `1.0`. No `X`, `-1` é esquerda. No `Y`, `-1` é **cima**
- Gatilhos (`GAMEPAD_AXIS_LEFT_TRIGGER`, `RIGHT_TRIGGER`): devolvem de `-1.0` (solto) a `1.0` (totalmente apertado)

```c
float x = GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X);
float y = GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y);

if (fabsf(x) < 0.15f) x = 0;   // zona morta
if (fabsf(y) < 0.15f) y = 0;

pos.x += x * 300 * dt;
pos.y += y * 300 * dt;

// acelerador: converte o gatilho de -1..1 para 0..1
float acelerador = (GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_TRIGGER) + 1.0f) / 2.0f;
```

---

**Zona morta**

- Um analógico parado raramente devolve exatamente `0`: o desgaste e a imprecisão do sensor geram valores como `0.02` ou `-0.07`
- Sem uma zona morta, o personagem "escorrega" sozinho. Valores entre `0.1` e `0.2` são comuns

> O analógico é um quadrado, e não um círculo, para o hardware: a diagonal pode chegar a `x = 1, y = 1`, um vetor de tamanho `√2`. Para velocidade uniforme em todas as direções, limite o tamanho do vetor a `1` (`Vector2ClampValue` ou normalizando quando passar de 1)
