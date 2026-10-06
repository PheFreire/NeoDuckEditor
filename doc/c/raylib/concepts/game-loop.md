**Game loop**

> conceito geral de programação de jogos

O game loop é o laço central de todo jogo: enquanto o jogo estiver aberto, ele lê o input, atualiza o estado do mundo e desenha o resultado, repetindo isso dezenas de vezes por segundo. Cada volta do laço produz um **frame**. Ao contrário de um programa comum, que espera o usuário fazer algo, o jogo continua rodando mesmo sem nenhum input, porque o mundo continua se movendo

```text
         ┌─────────────────────────────┐
         ▼                             │
   ler input  ──►  atualizar  ──►  desenhar
   (teclado,       (física,         (tudo na
    mouse)          lógica, IA)      posição atual)
```

```c
while (!WindowShouldClose()) {        // até o usuário fechar
  // 1. input + 2. atualização
  float dt = GetFrameTime();
  if (IsKeyDown(KEY_RIGHT)) jogador.x += 200 * dt;
  atualizar_inimigos(dt);
  verificar_colisoes();

  // 3. desenho
  BeginDrawing();
  ClearBackground(RAYWHITE);
  desenhar_mundo();
  desenhar_interface();
  EndDrawing();                       // mostra o frame e lê o input do próximo
}
```

---

**As três fases**

| Fase | O que faz | Regra |
|------|-----------|-------|
| input | lê o estado do teclado, mouse e controles | no raylib, o input já foi lido no `EndDrawing` anterior |
| atualização | move objetos, aplica física, IA, colisões, regras | não desenha nada |
| desenho | desenha o estado atual | não altera o estado do jogo |

- Separar atualização e desenho deixa o código mais fácil de entender: qualquer bug de lógica está na atualização, e qualquer problema visual no desenho

---

**Estados do jogo**

Um jogo normalmente tem várias telas (menu, jogo, pausa, game over). Um `enum` e um `switch` organizam qual atualização e qual desenho rodam:

```c
typedef enum { MENU, JOGANDO, PAUSADO, FIM } Estado;
Estado estado = MENU;

while (!WindowShouldClose()) {
  switch (estado) {
    case MENU:    if (IsKeyPressed(KEY_ENTER)) estado = JOGANDO; break;
    case JOGANDO: atualizar_jogo(GetFrameTime());
                  if (IsKeyPressed(KEY_P)) estado = PAUSADO; break;
    case PAUSADO: if (IsKeyPressed(KEY_P)) estado = JOGANDO; break;
    case FIM:     if (IsKeyPressed(KEY_R)) { reiniciar(); estado = JOGANDO; } break;
  }

  BeginDrawing();
  ClearBackground(RAYWHITE);
  switch (estado) {
    case MENU:    desenhar_menu(); break;
    case JOGANDO: desenhar_jogo(); break;
    case PAUSADO: desenhar_jogo(); desenhar_pausa(); break;
    case FIM:     desenhar_fim(); break;
  }
  EndDrawing();
}
```

- No estado `PAUSADO`, o jogo continua sendo **desenhado**, mas não **atualizado**: o mundo congela na tela (ver `../../control_flow/switch.md`)

> Como o laço roda muitas vezes por segundo, qualquer operação lenta dentro dele (carregar arquivos, alocar memória, laços enormes) é repetida em todo frame e derruba o FPS. Carregue recursos antes do laço, e mantenha a atualização e o desenho leves (ver `frame.md` e `fps.md`)
