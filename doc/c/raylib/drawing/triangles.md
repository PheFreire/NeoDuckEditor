**Triângulos**

> `raylib.h` — módulo `rshapes`

O triângulo é a forma básica de toda a renderização na GPU: retângulos, círculos, texto e modelos 3D são desenhados como triângulos. O raylib permite desenhar triângulos diretamente, sozinhos ou em sequências (fan e strip)

| Função | Desenha |
|--------|---------|
| `DrawTriangle(v1, v2, v3, cor)` | triângulo preenchido |
| `DrawTriangleLines(v1, v2, v3, cor)` | contorno |
| `DrawTriangleFan(pontos, n, cor)` | leque: todos os triângulos compartilham o primeiro ponto |
| `DrawTriangleStrip(pontos, n, cor)` | faixa: cada novo ponto forma um triângulo com os dois anteriores |

```c
Vector2 a = { 400, 100 };
Vector2 b = { 300, 300 };
Vector2 c = { 500, 300 };
DrawTriangle(a, b, c, GOLD);
```

---

**Ordem dos vértices**

```text
    a (400, 100)
       ▲
      ╱ ╲          a → b → c: sentido anti-horário na tela  → aparece
     ╱   ╲         a → c → b: sentido horário              → não aparece
    b ─── c
```

- O `DrawTriangle` espera os vértices em sentido **anti-horário** (na tela, com `y` para baixo). Na ordem contrária, o triângulo pode não ser desenhado, porque a GPU descarta triângulos "de costas" (back-face culling)
- Se um triângulo sumir sem motivo, troque a ordem de dois vértices

---

**Fan e strip**

```text
fan (leque)                       strip (faixa)
    p0                            p0───p2───p4
   ╱│╲                            │ ╲  │ ╲  │
  ╱ │ ╲                           │  ╲ │  ╲ │
p1──p2──p3                        p1───p3───p5
triângulos: (p0,p1,p2) (p0,p2,p3)  triângulos: (p0,p1,p2) (p1,p3,p2) ...
```

- Fan: bom para polígonos convexos, com o primeiro ponto no centro ou em um dos vértices
- Strip: bom para faixas e superfícies contínuas, como uma estrada ou o terreno de um jogo 2D

> Triângulos são a forma mais flexível de montar polígonos irregulares, como um terreno gerado proceduralmente. Para colisão com triângulos, veja `CheckCollisionPointTriangle` (ver `../collision/functions/check-collision-point-triangle.md`)
