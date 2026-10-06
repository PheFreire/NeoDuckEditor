**Frame**

> conceito geral de programação de jogos

Um frame é uma imagem completa mostrada na tela, e também uma volta do game loop que produz essa imagem. A ilusão de movimento vem de mostrar muitos frames por segundo, cada um com os objetos um pouco deslocados em relação ao anterior, como em um desenho animado

```text
frame 1        frame 2        frame 3        frame 4
  ●              ●              ●              ●
                   →              →              →
x = 100        x = 104        x = 108        x = 112
```

---

**O que acontece em um frame no raylib**

```text
início do frame
  │  GetFrameTime() → quanto o frame anterior levou
  ▼
atualização        posições, colisões, lógica
  ▼
BeginDrawing()
  │  Draw...()     comandos de desenho acumulados
  ▼
EndDrawing()
  │  envia o desenho à GPU e troca os buffers (o frame aparece)
  │  espera o tempo do SetTargetFPS
  │  lê os eventos de input para o próximo frame
  ▼
próximo frame
```

---

**Orçamento de tempo**

| FPS alvo | Tempo por frame |
|----------|-----------------|
| 30 | 33,3 ms |
| 60 | 16,6 ms |
| 120 | 8,3 ms |
| 144 | 6,9 ms |

- Tudo que acontece em um frame (atualizar e desenhar) precisa caber nesse tempo. Se passar, o FPS cai
- Uma operação de 5 ms, que parece rápida, consome quase um terço do orçamento a 60 FPS

---

**Estado entre frames**

- Variáveis locais dentro do game loop são recriadas a cada frame. O estado que precisa continuar (posição, vida, pontuação) deve ficar fora do laço, em variáveis declaradas antes dele ou em structs
- O input é uma fotografia do momento: `IsKeyPressed` é verdadeiro em um único frame, por isso a ação precisa acontecer naquele frame (ver `../input/input.md`)

> O conteúdo de um frame só aparece depois do `EndDrawing`. Em um debugger, parado no meio do desenho, a janela mostra o frame anterior, e não o que está sendo montado (ver `../drawing/drawing-cycle.md`)
