**DrawFPS**

> `raylib.h` — módulo `rtext`

O `DrawFPS` desenha o FPS atual na tela, com a fonte padrão e uma cor que indica o desempenho. É a forma mais rápida de acompanhar o desempenho durante o desenvolvimento

```c
void DrawFPS(int posX, int posY);
```

- `posX`, `posY`: o canto superior esquerdo do texto

- Não devolve nada
- Desenha `"XX FPS"` com tamanho 20, usando o valor do `GetFPS`
- A cor muda conforme o valor: verde para FPS alto, laranja para médio e vermelho para baixo (abaixo de 15)

```c
BeginDrawing();
ClearBackground(RAYWHITE);
desenhar_jogo();
DrawFPS(10, 10);   // desenhado por último, para ficar por cima
EndDrawing();
```

> Desenhe o `DrawFPS` fora do `BeginMode2D`/`BeginMode3D`, para que ele fique fixo na tela. Para mostrar o valor com outro formato ou fonte, use `DrawText(TextFormat("FPS: %d", GetFPS()), ...)` (ver `../../core/functions/get-fps.md`)
