**DrawLineEx**

> `raylib.h` — módulo `rshapes`

O `DrawLineEx` desenha uma linha reta com espessura escolhida, montada com triângulos. É a forma de desenhar linhas grossas e com espessura precisa

```c
void DrawLineEx(Vector2 startPos, Vector2 endPos, float thick, Color color);
```

- `startPos`: ponto inicial
- `endPos`: ponto final
- `thick`: espessura em pixels
- `color`: a cor da linha

- Não devolve nada
- A linha é um retângulo fino ao longo do segmento, centralizado na linha ideal: metade da espessura para cada lado
- As pontas são retas (sem arredondamento)

```c
// raio laser
DrawLineEx(arma, alvo, 6, Fade(RED, 0.4f));   // brilho largo e transparente
DrawLineEx(arma, alvo, 2, RED);               // núcleo fino por cima
```

---

**Pontas arredondadas**

Como as pontas são retas, linhas grossas ligadas em sequência deixam falhas nas junções. Desenhar um círculo em cada ponta resolve:

```c
void linha_arredondada(Vector2 a, Vector2 b, float espessura, Color cor) {
  DrawLineEx(a, b, espessura, cor);
  DrawCircleV(a, espessura / 2, cor);
  DrawCircleV(b, espessura / 2, cor);
}
```

> Para traços longos com várias junções, as splines tratam as emendas automaticamente (ver `../splines.md`)
