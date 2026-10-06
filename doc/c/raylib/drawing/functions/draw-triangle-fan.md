**DrawTriangleFan**

> `raylib.h` — módulo `rshapes`

O `DrawTriangleFan` desenha um leque de triângulos: o primeiro ponto é compartilhado por todos, e cada par de pontos seguintes forma um triângulo com ele. É a forma de desenhar polígonos convexos a partir de uma lista de vértices

```c
void DrawTriangleFan(const Vector2 *points, int pointCount, Color color);
```

- `points`: o array de vértices. O primeiro é o centro do leque
- `pointCount`: quantos pontos o array tem (mínimo de 3)
- `color`: a cor de preenchimento

- Não devolve nada
- Com `n` pontos, desenha `n - 2` triângulos: `(p0, p1, p2)`, `(p0, p2, p3)`, ...
- Os pontos devem seguir o sentido anti-horário, como no `DrawTriangle`

```c
// polígono convexo irregular, como uma pedra
Vector2 pedra[] = {
  { 400, 225 },                                   // centro
  { 460, 225 }, { 430, 180 }, { 380, 170 },
  { 340, 210 }, { 360, 270 }, { 420, 280 },
  { 460, 225 },                                   // repete o primeiro para fechar
};
DrawTriangleFan(pedra, 8, BROWN);
```

---

**Leque**

```text
        p3   p2
         ╲   │
     p4 ── p0 ── p1
         ╱   │
        p5   p6
```

> O leque só funciona bem para formas **convexas** (sem "reentrâncias") vistas a partir do primeiro ponto. Em um polígono côncavo, alguns triângulos saem para fora da forma
