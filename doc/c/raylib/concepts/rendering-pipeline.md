**Pipeline de renderização do raylib**

> do `DrawRectangle` até o pixel na tela

Quando o programa chama uma função `Draw...`, nada é desenhado na hora. O raylib acumula os vértices em um buffer (o **batch**) e os envia à GPU de uma vez, em poucos comandos. Esse agrupamento é o que permite desenhar milhares de formas por frame com bom desempenho. Como a textura chega até aqui, desde o arquivo, está em `image-to-screen.md`

```text
DrawRectangle / DrawTexture / DrawText ...
  │  rshapes / rtextures / rtext: convertem a forma em vértices (2 triângulos por retângulo)
  ▼
rlgl: render batch
  │  acumula vértices, coordenadas de textura e cores em um buffer na RAM
  │  enquanto a textura e o shader forem os mesmos, tudo vai para o mesmo grupo
  ▼
flush (envio para a GPU)
  │  acontece quando: muda a textura, muda o shader, muda o modo (BeginMode2D, Scissor...),
  │  o buffer enche, ou no EndDrawing
  ▼
GPU: vertex shader → rasterização → fragment shader → framebuffer
  ▼
EndDrawing: troca de buffers → o frame aparece
```

---

**Draw calls**

- Cada envio para a GPU é uma **draw call**. Draw calls têm um custo fixo na CPU e no driver, então poucas draw calls grandes são mais rápidas que muitas pequenas
- Desenhar 1000 retângulos seguidos (mesma textura branca, mesmo shader) gera poucas draw calls
- Alternar entre duas texturas a cada desenho força um flush a cada troca

```c
// lento: troca de textura a cada sprite → muitas draw calls
for (int i = 0; i < n; i++) {
  DrawTexture(i % 2 ? arvore : pedra, x[i], y[i], WHITE);
}

// rápido: todos os sprites em uma única textura (atlas), recortados com DrawTextureRec
for (int i = 0; i < n; i++) {
  DrawTextureRec(atlas, recortes[tipo[i]], (Vector2){ x[i], y[i] }, WHITE);
}
```

---

**Formas usam textura**

- Até as formas sem textura (`DrawRectangle`, `DrawCircle`) são desenhadas com uma textura branca de 1 pixel e a cor como tint
- Por isso formas e texto (que usa o atlas da fonte) intercalados também geram trocas de textura

---

**Por que a ordem importa**

- Em 2D, o que é desenhado depois aparece por cima, pois o batch preserva a ordem
- Em 3D, o depth buffer decide quem fica na frente para objetos opacos, independente da ordem. Transparências ainda precisam de ordem (do mais distante para o mais próximo)

> Para a maioria dos jogos 2D, o batch do raylib já é eficiente sem nenhum cuidado especial. Quando o FPS cai com muitos objetos, as primeiras otimizações são agrupar sprites em atlas e agrupar desenhos por shader (ver `../shaders/shader-pipeline.md`)
