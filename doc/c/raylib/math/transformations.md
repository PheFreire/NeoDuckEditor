**Transformações**

> `raymath.h`

Transformar um objeto é mudar a posição, a orientação ou o tamanho dele. As três transformações básicas (translação, rotação e escala) podem ser aplicadas diretamente nos vetores, ou combinadas em uma única matriz que é aplicada de uma vez

```text
escala:      multiplica cada coordenada       (2, 1) × 2      = (4, 2)
rotação:     gira em torno da origem          (1, 0) girado 90° = (0, 1)
translação:  soma um deslocamento             (1, 1) + (5, 0) = (6, 1)
```

---

**Com vetores (2D)**

```c
Vector2 ponto = { 10, 0 };   // relativo ao centro do objeto

ponto = Vector2Scale(ponto, 2.0f);                 // escala
ponto = Vector2Rotate(ponto, angulo);              // rotação (radianos)
ponto = Vector2Add(ponto, objeto.pos);             // translação: vai para a posição no mundo
```

- Útil para calcular onde fica a ponta de uma arma, a saída de um tiro ou os vértices de uma forma girada

---

**Com matrizes (3D)**

```c
Matrix m = MatrixMultiply(MatrixMultiply(MatrixScale(s, s, s),
                                         MatrixRotateY(ang)),
                          MatrixTranslate(pos.x, pos.y, pos.z));
Vector3 mundo = Vector3Transform(ponto_local, m);
```

---

**A ordem importa**

```text
escala → rotação → translação          translação → rotação
(gira no lugar e depois vai)           (vai e depois gira em torno da ORIGEM)

        ●  objeto girado                        ╲
        no lugar certo                ●──────────●  objeto orbitando a origem
```

- A ordem padrão é **escala, rotação, translação**: o objeto é escalado e girado em torno do próprio centro, e só depois levado até a posição
- Transladar primeiro faz a rotação acontecer em torno da origem do mundo, como um planeta em órbita. Isso é útil quando é o efeito desejado

---

**Hierarquias**

```c
// a arma segue a mão, que segue o braço, que segue o corpo
Matrix corpo = MatrixMultiply(MatrixRotateY(ang_corpo), MatrixTranslate(pos.x, pos.y, pos.z));
Matrix braco = MatrixMultiply(MatrixMultiply(MatrixRotateX(ang_braco), MatrixTranslate(0.5f, 1.2f, 0)), corpo);
Matrix arma  = MatrixMultiply(MatrixTranslate(0, -0.6f, 0), braco);
```

- A transformação de um objeto filho é a dele combinada com a do pai. Mover o pai move todos os filhos

> No raylib, `MatrixMultiply(a, b)` aplica `a` primeiro e `b` depois. Lendo a expressão de dentro para fora, a ordem da escrita é a ordem em que as transformações acontecem (ver `matrix.md`)
