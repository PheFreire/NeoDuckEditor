**SetTargetFPS**

> `raylib.h` — módulo `rcore`

O `SetTargetFPS` define a quantidade máxima de frames por segundo do game loop. O raylib faz o `EndDrawing` esperar o tempo necessário para que cada frame dure, no mínimo, `1 / fps` segundos

```c
void SetTargetFPS(int fps);
```

- `fps`: frames por segundo desejados. `0` ou um valor negativo remove o limite

- Não devolve nada
- É um **limite máximo**: se o frame demorar mais que o orçamento, o FPS real fica abaixo do alvo
- Normalmente chamado uma vez, logo depois do `InitWindow`

```c
InitWindow(800, 450, "jogo");
SetTargetFPS(60);   // cada frame dura pelo menos 16,6 ms
```

---

**O que acontece por baixo**

```text
SetTargetFPS(60)  →  tempo alvo por frame = 1 / 60 = 0,0166 s

EndDrawing()
  │  troca os buffers
  ▼
  │  mede quanto tempo o frame levou: 0,005 s
  ▼
  │  espera 0,0166 - 0,005 = 0,0116 s
  ▼
próximo frame
```

- A espera usa uma combinação de `sleep` do sistema e espera ativa (busy wait) no final, para ser precisa. Por isso o uso de CPU não cai a zero mesmo com o limite
- Sem limite, o loop roda o mais rápido possível: centenas ou milhares de FPS em cenas simples, com a CPU e a GPU a 100% e o computador esquentando sem necessidade

---

**SetTargetFPS vs V-Sync**

- `FLAG_VSYNC_HINT`: a troca de buffers espera o monitor, sincronizando os frames com a taxa dele e evitando "tearing" (a imagem cortada ao meio)
- `SetTargetFPS`: limite controlado pelo próprio raylib, sem relação com o monitor
- Usar os dois com valores diferentes (V-Sync a 144 Hz e `SetTargetFPS(60)`) pode causar travadas irregulares. Use o mesmo valor do monitor (`GetMonitorRefreshRate`) ou só um dos dois

> Mesmo com o FPS limitado, use sempre o `GetFrameTime` para movimento: o FPS real varia com o carregamento da máquina e cai em computadores mais lentos (ver `../../concepts/delta-time.md`)
