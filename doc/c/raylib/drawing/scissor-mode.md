**Scissor mode**

> `raylib.h` — módulo `rcore`

O scissor mode limita o desenho a uma área retangular da tela: tudo que for desenhado fora dela é cortado. É usado para janelas de rolagem, minimapas, caixas de texto e qualquer elemento de interface que não pode "vazar" para fora da sua área

```c
void BeginScissorMode(int x, int y, int width, int height);
void EndScissorMode(void);
```

```c
Rectangle painel = { 100, 100, 300, 200 };

DrawRectangleLinesEx(painel, 2, DARKGRAY);

BeginScissorMode(painel.x, painel.y, painel.width, painel.height);
  for (int i = 0; i < 50; i++) {
    DrawText(TextFormat("item %d", i), painel.x + 10, painel.y + 10 + i * 25 - rolagem, 20, BLACK);
  }
EndScissorMode();
```

- Os itens que passam da borda do painel são cortados exatamente na borda, em vez de aparecerem por cima do resto da tela

---

**Como funciona**

```text
tela inteira
┌────────────────────────────────────┐
│                                    │
│      ┌──────────────┐              │
│      │ área visível │ ← só esta    │
│      │ do scissor   │   região     │
│      └──────────────┘   recebe     │
│                         pixels     │
└────────────────────────────────────┘
```

- O raylib usa o "scissor test" do OpenGL: a GPU descarta todo pixel fora do retângulo, sem custo extra de desenho
- A área é em coordenadas da **tela**, mesmo dentro de um `BeginMode2D`. A câmera não afeta o retângulo do scissor

---

**Armadilhas**

- O scissor mode não pode ser aninhado: abrir um segundo `BeginScissorMode` substitui o primeiro, e o `EndScissorMode` desliga o corte por completo
- Sempre feche com `EndScissorMode`, ou o corte continua ativo para o resto do frame (inclusive a interface desenhada depois)

> Para áreas de desenho mais complexas (cortar por um formato que não é retângulo, aplicar efeitos), desenhe em uma render texture e depois desenhe a textura no lugar desejado (ver `../texture/render-texture.md`)
