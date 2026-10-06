**EndMode2D**

> `raylib.h` — módulo `rcore`

O `EndMode2D` desativa a câmera 2D iniciada pelo `BeginMode2D`. O que for desenhado depois volta a usar as coordenadas da tela

```c
void EndMode2D(void);
```

- Não recebe parâmetros e não devolve nada
- Envia à GPU o que foi desenhado com a câmera e restaura a matriz de transformação padrão

```c
BeginMode2D(camera);
  desenhar_mundo();
EndMode2D();

desenhar_hud();   // coordenadas da tela
```

> Esquecer o `EndMode2D` faz a interface ser desenhada com a transformação da câmera: ela passa a se mover com o mundo e a aumentar com o zoom. Se o HUD "andar" junto com o mapa, procure um `BeginMode2D` sem o par
