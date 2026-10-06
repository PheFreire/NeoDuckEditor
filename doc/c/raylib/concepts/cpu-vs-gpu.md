**CPU vs GPU**

> onde cada parte do jogo é processada

Um jogo usa dois processadores com papéis diferentes. A **CPU** executa o programa em C: lógica, input, física, IA, decisões. A **GPU** (placa de vídeo) desenha: transforma vértices, preenche triângulos e calcula a cor de milhões de pixels por frame. Cada uma tem a sua própria memória, e mover dados entre elas tem um custo

```text
         CPU + RAM                              GPU + VRAM
┌──────────────────────────┐         ┌──────────────────────────┐
│ programa em C            │         │ shaders                  │
│ lógica, input, física    │ ──────► │ vértices → triângulos    │
│ Image (pixels na RAM)    │ comandos│ → pixels                 │
│ Mesh (arrays na RAM)     │ e dados │ Texture2D, VBOs, FBOs    │
└──────────────────────────┘ ◄────── └──────────────────────────┘
          poucos núcleos,      lento        milhares de núcleos,
          lógica complexa                   operações simples em paralelo
```

---

**Quem faz o quê no raylib**

| CPU | GPU |
|-----|-----|
| `Image` e funções `Image...` | `Texture2D` e funções `DrawTexture...` |
| `ImageDraw...` (desenho pixel a pixel) | `Draw...` (formas, texto, texturas) |
| lógica do jogo, colisões, `raymath` | transformação dos vértices (`mvp`) |
| montar os comandos de desenho (batch) | rasterizar e colorir (shaders) |
| `UpdateModelAnimation` (no 5.5) | `DrawModel`, `DrawMesh` |

---

**O custo da transferência**

```text
LoadTextureFromImage / UpdateTexture   RAM → VRAM   aceitável, mas não para imagens grandes todo frame
LoadImageFromTexture / screenshot      VRAM → RAM   lento: a CPU espera a GPU terminar
```

- Envie uma vez e desenhe muitas vezes: texturas, meshes e fontes ficam na GPU e são desenhadas sem nova transferência
- Ler dados de volta da GPU todo frame força a CPU a esperar, e derruba o FPS

---

**Paralelismo**

- A GPU processa milhares de pixels ao mesmo tempo, mas cada um de forma independente. É ótima para "fazer a mesma conta em muitos dados" (efeitos de imagem, iluminação)
- A CPU é melhor em lógica com muitas decisões e dependências (IA, regras do jogo)
- Mover um efeito da CPU para um shader (por exemplo, escurecer a tela inteira) pode transformar um gargalo em algo praticamente gratuito (ver `../shaders/shaders.md`)

> A GPU só existe para o raylib depois do `InitWindow`, que cria o contexto OpenGL. Por isso funções de imagem (CPU) funcionam antes da janela existir, e funções de textura (GPU) não (ver `image-vs-texture.md`)
