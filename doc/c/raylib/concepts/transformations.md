**Transformações**

> do vértice do modelo ao pixel na tela

Para um objeto aparecer na tela, cada vértice dele passa por uma sequência de transformações: do espaço do próprio modelo para o mundo, do mundo para o ponto de vista da câmera, e da câmera para a tela. Cada etapa é uma matriz 4x4, e todas são combinadas em uma só, chamada **MVP** (model × view × projection)

```text
espaço do modelo      vértices em torno da origem do próprio objeto
      │  MODEL: escala, rotação, translação do objeto (DrawModelEx, model.transform)
      ▼
espaço do mundo       todos os objetos na mesma cena
      │  VIEW: posição e direção da câmera (Camera2D / Camera3D)
      ▼
espaço da câmera      a cena vista a partir da câmera
      │  PROJECTION: perspectiva ou ortográfica (fovy, projection)
      ▼
espaço de recorte     o que está fora do campo de visão é descartado
      │  divisão por w e viewport (feito pela GPU)
      ▼
tela                  pixels da janela
```

---

**Onde cada matriz vem no raylib**

| Matriz | Definida por |
|--------|--------------|
| model | `DrawModel`/`DrawModelEx` (posição, rotação, escala) + `model.transform`, ou a matriz do `DrawMesh` |
| view | a câmera: `BeginMode2D(camera2d)` ou `BeginMode3D(camera3d)` |
| projection | 2D: ortográfica do tamanho da tela. 3D: `camera.fovy` e `camera.projection` |

- O raylib combina as três e envia ao vertex shader como o uniform `mvp` (ver `../shaders/shader-pipeline.md`)

---

**Em 2D**

```text
sem câmera:   model = identidade, view = identidade, projection = tela
              → as coordenadas passadas ao Draw são os pixels da tela

com Camera2D: view = translação(-target) × rotação × zoom × translação(offset)
              → as coordenadas passadas ao Draw são do mundo
```

---

**A ordem das transformações**

- Em uma única matriz, a ordem em que as transformações são combinadas muda o resultado: girar e depois mover não é o mesmo que mover e depois girar
- A ordem padrão para um objeto é **escala → rotação → translação** (ver `../math/transformations.md`)

> Entender esse caminho explica comportamentos comuns: um objeto que "orbita" em vez de girar no lugar (ordem das transformações), um modelo que aparece minúsculo ou gigante (escala do modelo vs unidades do mundo), e objetos que somem perto da câmera (o plano de corte próximo da projeção)
