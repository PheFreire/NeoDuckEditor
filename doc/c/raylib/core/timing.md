**Tempo**

> `raylib.h` — módulo `rcore`

O raylib mede o tempo do programa em três formas: quantos frames são mostrados por segundo (FPS), quanto tempo o último frame levou (delta time) e quanto tempo passou desde que a janela foi criada. Com isso o programa limita a velocidade do game loop, faz o movimento ser igual em qualquer máquina e controla eventos com hora marcada

```c
SetTargetFPS(60);                 // limita o loop a 60 frames por segundo

while (!WindowShouldClose()) {
  float dt = GetFrameTime();      // segundos que o último frame levou (~0.0167 a 60 FPS)
  double agora = GetTime();       // segundos desde o InitWindow
  int fps = GetFPS();             // frames por segundo atuais
  /* ... */
}
```

---

**Funções**

| Função | Devolve | Uso |
|--------|---------|-----|
| `SetTargetFPS(fps)` | — | define o FPS máximo do game loop |
| `GetFrameTime()` | `float`, segundos | delta time: multiplica velocidades |
| `GetTime()` | `double`, segundos | tempo total, para timers e animações |
| `GetFPS()` | `int` | FPS médio recente, para mostrar na tela |

- Ver as notas de cada uma em `functions/`

---

**Como o limite de FPS funciona**

```text
frame com SetTargetFPS(60): orçamento de 16,6 ms

|── atualizar + desenhar (5 ms) ──|── EndDrawing espera (11,6 ms) ──|
                                                                    ▲ próximo frame começa
```

- O `EndDrawing` mede quanto tempo o frame levou e dorme o restante até completar `1 / fps` segundos
- Se o frame levar **mais** que o orçamento, não há espera, e o FPS real cai abaixo do alvo
- Sem `SetTargetFPS` (ou com `0`), o loop roda o mais rápido possível, usando 100% de um núcleo da CPU e da GPU
- Com `FLAG_VSYNC_HINT`, a troca de buffers espera o monitor, e o FPS fica limitado à taxa de atualização dele (ver `monitor.md`)

---

**Delta time**

```c
float velocidade = 200.0f;          // pixels por segundo
pos.x += velocidade * GetFrameTime();
```

- Multiplicar pela duração do frame transforma "pixels por frame" em "pixels por segundo": o objeto anda a mesma distância em um segundo a 30, 60 ou 144 FPS
- Sem o delta time, `pos.x += 3` move 180 pixels por segundo a 60 FPS e 432 a 144 FPS
- Ver a explicação completa em `../concepts/delta-time.md`

---

**Timers com GetTime**

```c
double proximo_tiro = 0;

if (IsKeyDown(KEY_SPACE) && GetTime() >= proximo_tiro) {
  atirar();
  proximo_tiro = GetTime() + 0.25;   // no máximo 4 tiros por segundo
}
```

- O `GetTime` devolve `double` para manter a precisão em programas que ficam muito tempo abertos. Um `float` perde precisão em milissegundos depois de algumas horas

> O `GetFPS` devolve uma média dos últimos frames, e não o valor exato do último. Para mostrá-lo na tela, o `DrawFPS(x, y)` já desenha o valor com cor verde, amarela ou vermelha conforme o desempenho (ver `../text/functions/draw-fps.md`)
