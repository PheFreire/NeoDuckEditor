**World space**

> espaço do mundo

O world space (espaço do mundo) é o sistema de coordenadas onde a simulação do jogo acontece. Posições, velocidades, distâncias e colisões dos objetos ficam nele, independentes de onde a câmera está, do zoom e do tamanho da janela

```text
mundo (o jogo inteiro)
┌─────────────────────────────────────────────────┐
│  árvore (200, 800)                               │
│                    jogador (1500, 900)           │
│                  ┌───────────────┐               │
│                  │ janela: só    │               │
│                  │ esta parte    │               │
│                  │ aparece       │               │
│                  └───────────────┘               │
│                                   baú (2800, 1700)│
└─────────────────────────────────────────────────┘
```

---

**Por que separar o mundo da tela**

- A lógica do jogo não muda quando a câmera se move: o jogador está em `(1500, 900)` esteja ele no centro da tela ou fora dela
- Mudar a resolução da janela, dar zoom ou girar a câmera não exige mexer em nenhuma posição de objeto
- Colisões funcionam entre objetos que estão longe da tela

---

**O que pertence ao mundo**

- Posições e tamanhos dos objetos do jogo
- Velocidades e acelerações
- Colisões e distâncias entre objetos
- Tudo desenhado entre `BeginMode2D` e `EndMode2D`, ou `BeginMode3D` e `EndMode3D`

---

**Escala**

- 2D: é comum 1 unidade do mundo = 1 pixel com zoom `1`
- 3D: é comum 1 unidade = 1 metro, o que deixa valores físicos naturais (gravidade `9.8`, personagem de `1.8` de altura)

> Ver como a câmera escolhe a parte do mundo que aparece em `../camera/camera-2d.md`, e a contraparte do mundo em `screen-space.md`
