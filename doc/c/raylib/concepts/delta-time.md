**Delta time**

> conceito geral de programação de jogos

O delta time é o tempo, em segundos, que o último frame levou. Multiplicar movimentos e mudanças por ele faz o jogo andar na mesma velocidade em qualquer computador, independente de quantos frames por segundo cada máquina consegue mostrar

```c
float dt = GetFrameTime();   // ~0.0167 a 60 FPS, ~0.0069 a 144 FPS
jogador.x += 200 * dt;        // 200 pixels por SEGUNDO, em qualquer FPS
```

---

**O problema sem delta time**

```text
jogador.x += 4 a cada frame

computador lento,  30 FPS:  120 pixels por segundo
computador normal, 60 FPS:  240 pixels por segundo
monitor de 144 Hz, 144 FPS: 576 pixels por segundo
```

- O mesmo jogo fica 4,8 vezes mais rápido em uma máquina do que em outra, e fica mais lento sempre que o FPS cai

---

**Com delta time**

```text
jogador.x += 240 * dt

 30 FPS: 30 frames × (240 × 0,0333) = 240 pixels por segundo
 60 FPS: 60 frames × (240 × 0,0167) = 240 pixels por segundo
144 FPS: 144 frames × (240 × 0,0069) = 240 pixels por segundo
```

- As velocidades passam a ser definidas por **segundo**, e não por frame

---

**O que multiplicar pelo dt**

| Multiplica | Não multiplica |
|------------|----------------|
| velocidade → posição: `pos += vel * dt` | o `GetMouseDelta` (já é o movimento do frame) |
| aceleração → velocidade: `vel += grav * dt` | ações únicas (`IsKeyPressed`: pular aplica uma velocidade inicial uma vez) |
| rotação contínua: `ang += 90 * dt` | valores absolutos (`pos = mouse`) |
| timers: `tempo += dt` | |

```c
// física de pulo com gravidade
const float GRAVIDADE = 1200.0f;   // pixels por segundo ao quadrado
if (IsKeyPressed(KEY_SPACE) && no_chao) vel_y = -500;   // impulso: sem dt
vel_y += GRAVIDADE * dt;                                // aceleração: com dt
pos_y += vel_y * dt;                                    // velocidade: com dt
```

---

**Limitar o delta time**

```c
float dt = GetFrameTime();
if (dt > 0.05f) dt = 0.05f;   // no máximo 50 ms por passo
```

- Um frame muito longo (janela arrastada, breakpoint, carregamento) gera um `dt` enorme, e um objeto pode atravessar paredes de uma vez (tunneling)
- Com o limite, o jogo fica um pouco mais lento nesses frames, mas não quebra

---

**Passo fixo para física**

```c
const float PASSO = 1.0f / 60.0f;
static float acumulado = 0;

acumulado += GetFrameTime();
while (acumulado >= PASSO) {
  atualizar_fisica(PASSO);   // sempre o mesmo dt: resultados idênticos em qualquer máquina
  acumulado -= PASSO;
}
```

> Com delta time variável, a física pode dar resultados ligeiramente diferentes conforme o FPS (um pulo um pouco mais alto a 30 FPS do que a 144). Jogos que precisam de física exata ou de replays usam o passo fixo acima, que roda a física sempre com o mesmo intervalo (ver `fps.md`)
