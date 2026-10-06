**BeginScissorMode**

> `raylib.h` — módulo `rcore`

O `BeginScissorMode` limita o desenho a um retângulo da tela: tudo que for desenhado fora dele, até o `EndScissorMode`, é descartado

```c
void BeginScissorMode(int x, int y, int width, int height);
```

- `x`, `y`: o canto superior esquerdo da área visível, em coordenadas da tela
- `width`, `height`: o tamanho da área visível

- Não devolve nada
- A área é sempre em coordenadas da **tela**, mesmo dentro de um `BeginMode2D`
- Envia à GPU o que estava acumulado antes de ativar o corte, para que o desenho anterior não seja cortado

```c
// minimapa no canto da tela, mostrando só a região dele
Rectangle mini = { GetScreenWidth() - 210, 10, 200, 150 };

BeginScissorMode(mini.x, mini.y, mini.width, mini.height);
  ClearBackground(DARKGRAY);   // limpa só a área do scissor
  BeginMode2D(camera_minimapa);
    desenhar_mapa();
  EndMode2D();
EndScissorMode();

DrawRectangleLinesEx(mini, 2, WHITE);
```

- Dentro do scissor mode, até o `ClearBackground` respeita o corte, limpando só a área visível

> Abrir outro `BeginScissorMode` antes de fechar o primeiro substitui a área, sem combinar as duas. Para regiões aninhadas, calcule a interseção manualmente com `GetCollisionRec` (ver `../scissor-mode.md`)
