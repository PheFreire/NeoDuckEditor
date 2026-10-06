**EndMode3D**

> `raylib.h` — módulo `rcore`

O `EndMode3D` termina o desenho 3D iniciado pelo `BeginMode3D` e volta ao modo 2D padrão, em que as coordenadas são as da tela

```c
void EndMode3D(void);
```

- Não recebe parâmetros e não devolve nada
- Envia à GPU o que foi desenhado em 3D, restaura as matrizes de projeção e visão 2D e desliga o teste de profundidade

```c
BeginMode3D(camera);
  DrawModel(cenario, (Vector3){ 0 }, 1.0f, WHITE);
EndMode3D();

// tudo que vem depois é 2D, por cima da cena 3D
DrawText("Missão: encontrar a chave", 10, 10, 20, WHITE);
DrawFPS(10, 40);
```

> A interface 2D desenhada depois do `EndMode3D` sempre aparece por cima da cena 3D, pois o teste de profundidade está desligado. É assim que se faz o HUD de jogos 3D
