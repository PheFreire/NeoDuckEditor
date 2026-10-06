**Coordenadas**

> sistemas de coordenadas no raylib

Uma coordenada é um conjunto de números que diz onde algo está. O raylib usa sistemas diferentes conforme o contexto: a tela 2D tem a origem no canto superior esquerdo com `y` para baixo, enquanto o espaço 3D tem `y` para cima. Saber em qual sistema cada valor está evita a maior parte dos erros de posição

```text
TELA 2D (pixels)                         ESPAÇO 3D (unidades)
(0,0) ──────────► x                              y (cima)
  │                                              │
  │                                              │
  ▼                                              └──────► x
  y (para baixo)                                ╱
                                               z (para o observador)
```

---

**Os sistemas**

| Sistema | Origem | Eixos | Onde aparece |
|---------|--------|-------|--------------|
| tela | canto superior esquerdo da janela | `x` direita, `y` baixo | mouse, interface, desenho sem câmera |
| mundo 2D | escolhida pelo jogo | igual à tela | objetos do jogo com `Camera2D` |
| mundo 3D | escolhida pelo jogo | `x` direita, `y` cima, `z` para o observador | modelos com `Camera3D` |
| textura | canto superior esquerdo da imagem | `x` direita, `y` baixo | `source` do `DrawTextureRec`/`Pro` |
| coordenada de textura (UV) | um canto da textura | de `0` a `1` | vértices de meshes, shaders |

---

**Por que o y cresce para baixo na tela**

- Telas são desenhadas linha por linha, de cima para baixo, e a memória das imagens segue essa ordem. O primeiro pixel da memória é o do canto superior esquerdo
- Consequências: subir é **diminuir** `y`, a gravidade é **positiva** em `y`, e ângulos positivos giram no sentido **horário**

---

**Convertendo entre sistemas**

```text
tela  ◄─── GetWorldToScreen2D / GetWorldToScreen ───  mundo
tela  ─── GetScreenToWorld2D / GetScreenToWorldRay ──► mundo
```

- O mouse está na tela. Para clicar em objetos do mundo, converta a posição dele (ver `../camera/coordinate-conversion.md`)

> Ao misturar sistemas, mantenha uma regra clara no código: por exemplo, todas as posições de objetos em coordenadas do mundo, e só converter para a tela na hora de desenhar a interface (ver `world-space.md` e `screen-space.md`)
