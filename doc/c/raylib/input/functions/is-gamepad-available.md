**IsGamepadAvailable**

> `raylib.h` — módulo `rcore`

O `IsGamepadAvailable` verifica se há um gamepad conectado em uma posição. Deve ser consultado antes de ler os botões e eixos de um controle, pois o controle pode ser conectado ou desconectado a qualquer momento

```c
bool IsGamepadAvailable(int gamepad);
```

- `gamepad`: índice do controle, de `0` a `3`

- Devolve `true` se há um controle conectado nesse índice, e `false` caso contrário
- O primeiro controle conectado ocupa o índice `0`, o segundo o `1`, e assim por diante

```c
for (int gp = 0; gp < 4; gp++) {
  if (IsGamepadAvailable(gp)) {
    DrawText(TextFormat("Jogador %d: %s", gp + 1, GetGamepadName(gp)), 10, 10 + gp * 25, 20, DARKGRAY);
  }
}
```

---

**Teclado ou controle**

```c
Vector2 dir = { 0 };

if (IsGamepadAvailable(0)) {
  dir.x = GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X);
  dir.y = GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y);
}
if (IsKeyDown(KEY_RIGHT)) dir.x = 1;   // o teclado continua funcionando junto
if (IsKeyDown(KEY_LEFT))  dir.x = -1;
```

> Um controle desconectado durante o jogo faz o `IsGamepadAvailable` voltar a `false`. Jogos costumam pausar automaticamente nesse caso, em vez de deixar o personagem parado sem controle
