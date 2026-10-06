**GetTime**

> `raylib.h` — módulo `rcore`

O `GetTime` devolve quantos segundos se passaram desde o `InitWindow`. É o relógio do programa, usado para timers, cooldowns, animações baseadas em tempo e para medir quanto algo demorou

```c
double GetTime(void);
```

- Devolve o tempo decorrido desde o `InitWindow`, em segundos, com casas decimais (precisão de microssegundos)
- Usa um relógio monotônico: não volta atrás se o usuário mudar a hora do sistema

```c
double inicio = GetTime();

while (!WindowShouldClose()) {
  double passado = GetTime() - inicio;

  BeginDrawing();
  ClearBackground(RAYWHITE);
  DrawText(TextFormat("%.1f s", passado), 10, 10, 20, DARKGRAY);
  EndDrawing();
}
```

---

**Usos comuns**

Cooldown de uma ação:

```c
double proximo_pulo = 0;
if (IsKeyPressed(KEY_SPACE) && GetTime() >= proximo_pulo) {
  pular();
  proximo_pulo = GetTime() + 0.5;   // meio segundo até o próximo
}
```

Animação contínua:

```c
float escala = 1.0f + 0.1f * sinf((float)GetTime() * 4.0f);   // pulsa 4 radianos por segundo
DrawCircle(400, 225, 50 * escala, RED);
```

Medir o tempo de uma operação:

```c
double t0 = GetTime();
gerar_mapa();
TraceLog(LOG_INFO, "mapa gerado em %.3f s", GetTime() - t0);
```

---

**GetTime vs GetFrameTime**

| | `GetTime` | `GetFrameTime` |
|---|---|---|
| O que mede | tempo total desde o início | duração do último frame |
| Tipo | `double` | `float` |
| Uso | timers, eventos marcados, animação por tempo absoluto | movimento e física por frame |

> O retorno é `double` porque um `float` tem só cerca de 7 dígitos de precisão: depois de algumas horas com o programa aberto, ele não consegue mais distinguir milissegundos. Ao fazer contas, mantenha em `double` e converta para `float` só no final
