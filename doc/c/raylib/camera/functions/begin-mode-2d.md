**BeginMode2D**

> `raylib.h` — módulo `rcore`

O `BeginMode2D` ativa uma câmera 2D: tudo que for desenhado até o `EndMode2D` é transformado pela câmera (deslocado, girado e escalado), como se fosse visto através dela

```c
void BeginMode2D(Camera2D camera);
```

- `camera`: a câmera, com `offset`, `target`, `rotation` e `zoom`

- Não devolve nada
- Deve ser chamado dentro de `BeginDrawing`/`EndDrawing` (ou de `BeginTextureMode`/`EndTextureMode`)
- As posições passadas aos `Draw...` dentro do bloco são do **mundo**

```c
BeginDrawing();
ClearBackground(RAYWHITE);

BeginMode2D(camera);
  DrawRectangle(0, 0, 3000, 2000, LIGHTGRAY);   // o mapa inteiro
  DrawCircleV(jogador, 16, BLUE);
EndMode2D();

DrawText("vida: 3", 10, 10, 20, BLACK);   // fora da câmera: fixo na tela
EndDrawing();
```

---

**O que acontece por baixo**

```text
BeginMode2D(camera)
  │  envia à GPU o que estava acumulado (com a transformação anterior)
  ▼
  │  calcula a matriz da câmera:
  │  translação(-target) → rotação → escala(zoom) → translação(offset)
  ▼
  │  aplica a matriz a todos os vértices desenhados a seguir
  ▼
EndMode2D()  → volta à matriz identidade
```

- A ordem das transformações faz o `target` virar a origem, girar e escalar em torno dele, e depois ir para o `offset` na tela
- A matriz pode ser obtida com `GetCameraMatrix2D(camera)`, útil para cálculos próprios

> Não é possível aninhar dois `BeginMode2D`: o segundo substitui o primeiro. Para várias visões (tela dividida, minimapa), desenhe cada uma em sequência, com scissor mode ou em render textures separadas (ver `../camera-2d.md`)
