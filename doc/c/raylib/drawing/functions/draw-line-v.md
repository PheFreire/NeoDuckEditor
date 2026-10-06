**DrawLineV**

> `raylib.h` — módulo `rshapes`

O `DrawLineV` desenha uma linha reta de 1 pixel entre dois pontos dados como `Vector2`. É a versão do `DrawLine` para posições em ponto flutuante

```c
void DrawLineV(Vector2 startPos, Vector2 endPos, Color color);
```

- `startPos`: ponto inicial
- `endPos`: ponto final
- `color`: a cor da linha

- Não devolve nada
- Usa a primitiva de linha do OpenGL, com espessura de 1 pixel

```c
// mostrar a velocidade de um objeto como um vetor
Vector2 ponta = Vector2Add(bola.pos, Vector2Scale(bola.vel, 0.2f));
DrawLineV(bola.pos, ponta, GREEN);

// ligar os pontos de um caminho
for (int i = 0; i < n - 1; i++) {
  DrawLineV(caminho[i], caminho[i + 1], GRAY);
}
```

> Para ligar uma lista inteira de pontos de uma vez, o `DrawLineStrip(pontos, n, cor)` faz o mesmo laço acima em uma chamada (ver `../lines.md`)
