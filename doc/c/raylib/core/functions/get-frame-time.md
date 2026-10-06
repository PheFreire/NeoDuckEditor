**GetFrameTime**

> `raylib.h` — módulo `rcore`

O `GetFrameTime` devolve quanto tempo, em segundos, o último frame levou para ser processado e mostrado. Esse valor é o **delta time**, usado para fazer movimentos, animações e física andarem na mesma velocidade independente do FPS

```c
float GetFrameTime(void);
```

- Devolve a duração do último frame, em segundos. A 60 FPS, cerca de `0.0167`
- No primeiro frame, devolve `0` ou um valor muito pequeno

```c
Vector2 pos = { 100, 100 };
const float velocidade = 250.0f;   // pixels por segundo

while (!WindowShouldClose()) {
  float dt = GetFrameTime();
  if (IsKeyDown(KEY_RIGHT)) pos.x += velocidade * dt;
  if (IsKeyDown(KEY_LEFT))  pos.x -= velocidade * dt;
  /* ... */
}
```

---

**Por que multiplicar pelo delta time**

```text
sem dt: pos.x += 4           com dt: pos.x += 240 * dt

 30 FPS → 120 px/s            30 FPS → 30 x (240 x 0,0333) = 240 px/s
 60 FPS → 240 px/s            60 FPS → 60 x (240 x 0,0167) = 240 px/s
144 FPS → 576 px/s           144 FPS → 144 x (240 x 0,0069) = 240 px/s
```

- A velocidade passa a ser definida em **unidades por segundo**, e não por frame

---

**Armadilhas**

- Um frame muito longo (janela arrastada, carregamento, breakpoint no debugger) gera um delta time enorme, e um objeto rápido pode atravessar uma parede inteira em um único passo. Limite o valor:

```c
float dt = GetFrameTime();
if (dt > 0.05f) dt = 0.05f;   // nunca simula mais que 50 ms de uma vez
```

- Física com delta time variável não é determinística: a mesma partida pode ter resultados levemente diferentes em máquinas diferentes. Para física precisa, use passos fixos (ver `../../concepts/delta-time.md`)

> O valor é medido pelo `EndDrawing` e inclui a espera do `SetTargetFPS`. Por isso, chame o `GetFrameTime` uma vez no começo do frame e use a mesma variável em toda a atualização
