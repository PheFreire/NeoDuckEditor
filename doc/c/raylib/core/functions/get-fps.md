**GetFPS**

> `raylib.h` — módulo `rcore`

O `GetFPS` devolve quantos frames por segundo o programa está mostrando, calculado como uma média dos últimos frames. É usado para exibir o desempenho e para diagnosticar quedas de FPS

```c
int GetFPS(void);
```

- Devolve o FPS médio recente, como inteiro
- A média suaviza variações: o número na tela não pula a cada frame

```c
BeginDrawing();
ClearBackground(RAYWHITE);
DrawText(TextFormat("FPS: %d", GetFPS()), 10, 10, 20, DARKGRAY);
EndDrawing();
```

---

**Interpretando o valor**

- Igual ao `SetTargetFPS`: o programa tem folga, e a espera no `EndDrawing` está completando o tempo
- Abaixo do alvo: algum frame está levando mais que o orçamento (`1 / fps` segundos). O gargalo pode ser a CPU (lógica, muitos objetos) ou a GPU (muitos desenhos, texturas grandes, shaders pesados)
- Sem `SetTargetFPS` e sem V-Sync, mostra o máximo que a máquina consegue

> O `DrawFPS(x, y)` faz o mesmo que o exemplo acima e ainda muda a cor conforme o valor (verde, amarelo, vermelho), sendo a forma mais rápida de mostrar o FPS durante o desenvolvimento (ver `../../text/functions/draw-fps.md`). Para saber quanto um frame específico demorou, use o `GetFrameTime`
