**EndDrawing**

> `raylib.h` — módulo `rcore`

O `EndDrawing` termina o desenho do frame e o mostra na janela. Além disso, é nele que o raylib controla o FPS e lê os eventos de input para o próximo frame, o que faz dele uma das funções mais importantes do game loop

```c
void EndDrawing(void);
```

- Não recebe parâmetros e não devolve nada
- Deve fechar o `BeginDrawing` do mesmo frame

---

**O que acontece por baixo**

```text
EndDrawing()
  │  1. envia à GPU todos os triângulos acumulados pelos Draw... (flush do batch)
  ▼
  │  2. troca os buffers: o frame desenhado aparece na tela (swap buffers)
  ▼
  │  3. mede quanto o frame levou e espera para respeitar o SetTargetFPS
  ▼
  │  4. lê os eventos da janela, do teclado, do mouse e do gamepad
  ▼
próximo frame
```

- **1. Flush**: os `Draw...` não desenham na hora. Eles acumulam vértices em um buffer, que é enviado de uma vez aqui (ver `../../concepts/rendering-pipeline.md`)
- **2. Swap**: com double buffering, o frame só aparece completo (ver `../drawing-cycle.md`)
- **3. Espera**: é por isso que o programa não usa 100% da CPU com `SetTargetFPS` (ver `../../core/functions/set-target-fps.md`)
- **4. Eventos**: o estado de `IsKeyPressed`, `WindowShouldClose` e afins só muda aqui (ver `../../input/input.md`)

---

**Armadilhas**

- Um caminho do game loop que não chama `EndDrawing` (por exemplo, um `continue` antes dele) deixa a janela congelada e sem responder, pois os eventos não são lidos
- Chamar `EndDrawing` duas vezes no mesmo frame conta dois frames: o FPS e o delta time ficam errados, e o input "pula" um frame

> Em uma depuração passo a passo, o conteúdo da janela só muda depois do `EndDrawing`. Ver a tela vazia logo depois de uma chamada `Draw...` no debugger é o comportamento esperado
