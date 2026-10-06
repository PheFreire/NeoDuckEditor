**GetGamepadAxisCount**

> `raylib.h` — módulo `rcore`

O `GetGamepadAxisCount` devolve quantos eixos analógicos um gamepad tem. Um controle padrão tem 6: dois eixos em cada analógico e um em cada gatilho

```c
int GetGamepadAxisCount(int gamepad);
```

- `gamepad`: índice do controle, de `0` a `3`

- Devolve a quantidade de eixos do controle, ou `0` se não houver controle nesse índice

```c
// tela de diagnóstico: mostra o valor de todos os eixos
int eixos = GetGamepadAxisCount(0);
for (int i = 0; i < eixos; i++) {
  float v = GetGamepadAxisMovement(0, i);
  DrawText(TextFormat("eixo %d: %+.2f", i, v), 20, 20 + i * 25, 20, DARKGRAY);
  DrawRectangle(200, 22 + i * 25, (int)(v * 100), 15, BLUE);
}
```

> Em jogos normais, os eixos são acessados pelas constantes `GAMEPAD_AXIS_*`, e a contagem não é necessária. Ela é útil em telas de teste e de configuração de controles, e para detectar controles incomuns (volantes, joysticks de voo) que têm mais eixos
