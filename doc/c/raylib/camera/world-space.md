**Espaço do mundo**

> world space

O espaço do mundo é o sistema de coordenadas onde os objetos do jogo existem. A posição de um personagem, de uma parede ou de uma moeda é guardada no espaço do mundo, e não depende de onde a câmera está ou do tamanho da janela

```text
MUNDO (mapa de 3000 x 2000 unidades)
┌─────────────────────────────────────────────┐
│                                             │
│   moeda (500, 300)        ┌──────────┐      │
│                           │ o que a  │      │
│          jogador (1200, 900)  câmera │      │
│                           │ mostra   │      │
│                           └──────────┘      │
│                                             │
└─────────────────────────────────────────────┘
```

- Um objeto em `(1200, 900)` está nessa posição do mundo sempre, esteja ele na tela ou não
- A câmera escolhe qual região do mundo aparece na janela (ver `camera-2d.md`)

---

**O que fica no espaço do mundo**

- Posições, velocidades e tamanhos dos objetos do jogo
- Colisões entre objetos do jogo: as duas formas precisam estar no mesmo espaço
- Tudo que é desenhado entre `BeginMode2D` e `EndMode2D` (ou `BeginMode3D` e `EndMode3D`)

---

**Unidades**

- Em 2D, é comum usar a unidade do mundo igual a 1 pixel com zoom `1`. Assim, um sprite de 32 pixels mede 32 unidades
- Em 3D, a unidade é abstrata. A convenção mais comum é `1 unidade = 1 metro`, o que facilita valores de gravidade (`9.8`) e tamanhos (um personagem de `1.8` de altura)
- O que importa é ser consistente: velocidades, tamanhos e distâncias na mesma escala

> Separar o mundo da tela é o que permite mudar a resolução, dar zoom ou mover a câmera sem mexer em nenhuma posição do jogo. Ver o espaço da tela em `screen-space.md` e a conversão entre os dois em `coordinate-conversion.md`
