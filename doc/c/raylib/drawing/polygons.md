**Polígonos regulares**

> `raylib.h` — módulo `rshapes`

As funções de polígono desenham polígonos regulares (todos os lados iguais): triângulo equilátero, quadrado, pentágono, hexágono, etc. O polígono é definido pelo centro, pela quantidade de lados, pelo raio e por uma rotação

| Função | Desenha |
|--------|---------|
| `DrawPoly(centro, lados, raio, rotação, cor)` | polígono preenchido |
| `DrawPolyLines(centro, lados, raio, rotação, cor)` | contorno de 1 pixel |
| `DrawPolyLinesEx(centro, lados, raio, rotação, espessura, cor)` | contorno com espessura |

```c
DrawPoly((Vector2){ 200, 225 }, 6, 60, 0, SKYBLUE);         // hexágono
DrawPolyLines((Vector2){ 400, 225 }, 5, 60, 0, DARKBLUE);   // pentágono
DrawPoly((Vector2){ 600, 225 }, 3, 60, GetTime() * 90, RED);  // triângulo girando 90 graus por segundo
```

---

**Geometria**

```text
         vértice
            ●
          ╱   ╲
        ╱       ╲
      ●    ● ────●    raio = distância do centro até cada vértice
       ╲  centro ╱
        ●───────●
```

- O `raio` é a distância do centro até os **vértices**, e não até o meio dos lados. Um quadrado de raio `50` tem lados de cerca de `70` pixels (`50 x √2`)
- A `rotação` é em graus. Com rotação `0`, o primeiro vértice aponta para a direita

---

**Mapa hexagonal**

```c
float raio = 30;
float largura = sqrtf(3.0f) * raio;   // distância entre centros na horizontal
float altura  = 1.5f * raio;          // distância entre linhas

for (int lin = 0; lin < 8; lin++) {
  for (int col = 0; col < 12; col++) {
    float x = col * largura + (lin % 2) * largura / 2 + 50;
    float y = lin * altura + 50;
    DrawPolyLines((Vector2){ x, y }, 6, raio, 30, GRAY);   // rotação 30: vértice para cima
  }
}
```

> Com muitos lados (`lados = 64`), o polígono parece um círculo. É exatamente assim que o `DrawCircle` funciona internamente (ver `circles.md`)
