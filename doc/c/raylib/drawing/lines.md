**Linhas**

> `raylib.h` — módulo `rshapes`

As funções de linha desenham segmentos retos entre dois pontos, com espessura fixa de 1 pixel ou com espessura escolhida, e também sequências de linhas ligadas

| Função | Desenha |
|--------|---------|
| `DrawLine(x1, y1, x2, y2, cor)` | linha de 1 pixel, com coordenadas `int` |
| `DrawLineV(inicio, fim, cor)` | linha de 1 pixel, com `Vector2` |
| `DrawLineEx(inicio, fim, espessura, cor)` | linha com espessura em pixels |
| `DrawLineStrip(pontos, n, cor)` | linhas ligando uma sequência de pontos |
| `DrawLineBezier(inicio, fim, espessura, cor)` | curva suave em "S" entre dois pontos |

```c
DrawLine(0, 225, 800, 225, LIGHTGRAY);                              // linha do horizonte
DrawLineV(jogador, inimigo, RED);                                    // linha de mira
DrawLineEx((Vector2){ 100, 100 }, (Vector2){ 300, 200 }, 5, BLUE);   // linha grossa
```

---

**Linha fina vs linha com espessura**

```text
DrawLine / DrawLineV            DrawLineEx
────────────────────            ───────────
primitiva GL_LINES              2 triângulos formando um retângulo
sempre 1 pixel                  qualquer espessura
pode ficar irregular            bordas mais consistentes
```

- `DrawLine` e `DrawLineV` usam a primitiva de linha do OpenGL, cuja aparência depende do driver
- `DrawLineEx` monta um retângulo fino ao longo da linha, com a espessura exata pedida. Para linhas de interface ou desenhos que precisam de precisão, prefira ela

---

**Grade**

```c
for (int x = 0; x <= GetScreenWidth(); x += 32) {
  DrawLine(x, 0, x, GetScreenHeight(), Fade(GRAY, 0.3f));
}
for (int y = 0; y <= GetScreenHeight(); y += 32) {
  DrawLine(0, y, GetScreenWidth(), y, Fade(GRAY, 0.3f));
}
```

> Ligar os pontos de uma lista com várias chamadas `DrawLineEx` deixa pequenos buracos nas junções, pois cada segmento termina reto. Para traços contínuos e grossos, use as splines (`DrawSplineLinear`), que tratam as junções (ver `splines.md`)
