**FPS**

> conceito geral de programação de jogos

FPS (frames per second, quadros por segundo) é quantos frames o jogo mostra a cada segundo. Mais FPS significa movimento mais fluido e resposta mais rápida ao input. O FPS depende de quanto trabalho cada frame tem e da velocidade da máquina, e pode ser limitado pelo programa ou pelo monitor

| FPS | Sensação |
|-----|----------|
| abaixo de 30 | travado, perceptível |
| 30 | aceitável para jogos lentos |
| 60 | fluido, padrão para a maioria dos jogos |
| 120 a 240 | muito fluido, útil em monitores de alta taxa e jogos competitivos |

---

**Quem define o FPS**

```text
FPS real = o menor entre:
  ├─ o limite do programa (SetTargetFPS)
  ├─ o limite do monitor (com V-Sync, FLAG_VSYNC_HINT)
  └─ o que a máquina consegue (tempo de atualizar + desenhar)
```

```c
SetTargetFPS(60);              // o programa não passa de 60
DrawFPS(10, 10);               // mostra o FPS atual
float dt = GetFrameTime();     // o tempo real de cada frame
```

---

**FPS e tempo de frame**

```text
tempo de frame (ms) = 1000 / FPS

60 FPS  → 16,6 ms
30 FPS  → 33,3 ms
```

- Para medir desempenho, o tempo de frame é mais útil que o FPS: cair de 60 para 50 FPS significa 3,4 ms a mais por frame, mas cair de 200 para 190 é só 0,26 ms
- Quedas pontuais (um frame que demora 100 ms) aparecem como "engasgos" mesmo com FPS médio alto

---

**Monitor e V-Sync**

- O monitor mostra uma nova imagem em intervalos fixos (60 Hz, 144 Hz). Um FPS maior que a taxa do monitor produz frames que nunca aparecem
- Sem sincronização, uma troca de buffer no meio da atualização do monitor mostra metade de um frame e metade de outro (tearing)
- Com `FLAG_VSYNC_HINT`, a troca espera o monitor: sem tearing, com o FPS limitado à taxa dele (ver `../core/timing.md`)

> O jogo deve funcionar corretamente em qualquer FPS: a lógica usa o delta time, e o FPS só muda a fluidez, e não a velocidade do jogo (ver `delta-time.md`)
