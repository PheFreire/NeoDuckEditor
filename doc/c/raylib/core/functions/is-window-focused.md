**IsWindowFocused**

> `raylib.h` — módulo `rcore`

O `IsWindowFocused` verifica se a janela do programa está em foco, ou seja, se é a janela ativa que recebe o teclado. Quando o usuário clica em outro programa, a janela perde o foco

```c
bool IsWindowFocused(void);
```

- Devolve `true` se a janela está em foco, e `false` caso contrário

```c
bool pausado = false;

while (!WindowShouldClose()) {
  if (!IsWindowFocused()) {
    pausado = true;            // pausa automaticamente ao trocar de janela
  }
  if (pausado && IsKeyPressed(KEY_P)) {
    pausado = false;
  }

  if (!pausado) {
    atualizar(GetFrameTime());
  }

  BeginDrawing();
  desenhar();
  if (pausado) DrawText("PAUSADO", 350, 200, 30, GRAY);
  EndDrawing();
}
```

---

**Comportamento**

- Sem foco, o teclado não chega ao programa: `IsKeyDown` devolve `false` para todas as teclas, mesmo que o usuário estivesse segurando uma quando trocou de janela
- O mouse ainda pode gerar posição se passar por cima da janela, dependendo do sistema
- O game loop continua rodando sem foco (diferente de minimizada). Para economizar CPU em segundo plano, o programa pode reduzir o FPS: `SetTargetFPS(IsWindowFocused() ? 60 : 10)`

> Pausar ao perder o foco é uma boa prática em jogos de ação: o jogador que troca de janela no meio da partida não volta e encontra o personagem morto
