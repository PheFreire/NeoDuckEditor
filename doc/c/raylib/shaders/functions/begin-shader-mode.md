**BeginShaderMode**

> `raylib.h` — módulo `rcore`

O `BeginShaderMode` ativa um shader próprio para os desenhos 2D seguintes (formas, texturas, texto), até o `EndShaderMode`

```c
void BeginShaderMode(Shader shader);
```

- `shader`: o shader a usar

- Não devolve nada
- Envia à GPU o que estava acumulado com o shader anterior antes de trocar
- Não afeta `DrawModel`/`DrawMesh`, que usam o shader do material do modelo

```c
BeginDrawing();
ClearBackground(BLACK);

BeginShaderMode(brilho);
  for (int i = 0; i < n_moedas; i++) DrawTextureV(moeda, moedas[i], WHITE);
EndShaderMode();

DrawText("Moedas brilhando", 10, 10, 20, WHITE);
EndDrawing();
```

> Agrupe os desenhos que usam o mesmo shader em um único bloco. Cada troca de shader força um envio separado para a GPU (ver `../shader-mode.md`)
