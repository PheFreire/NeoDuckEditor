**DrawPixel**

> `raylib.h` — módulo `rshapes`

O `DrawPixel` desenha um único ponto de 1 pixel na posição indicada. Existe também a versão `DrawPixelV`, que recebe a posição como `Vector2`

```c
void DrawPixel(int posX, int posY, Color color);
void DrawPixelV(Vector2 position, Color color);
```

- `posX`, `posY` / `position`: coordenadas do pixel na tela
- `color`: a cor do pixel

- Não devolve nada
- Cada pixel é desenhado como uma pequena geometria (um quadrado de 1x1), e não escrito direto na memória da tela

```c
// pontos de um gráfico
for (int x = 0; x < 800; x++) {
  int y = 225 - (int)(sinf(x * 0.02f) * 100);
  DrawPixel(x, y, RED);
}
```

> O próprio header do raylib avisa que o `DrawPixel` pode ser lento. Para muitos pixels por frame, monte os dados em um array de `Color` e envie como textura com `UpdateTexture` (ver `../pixels.md`)
