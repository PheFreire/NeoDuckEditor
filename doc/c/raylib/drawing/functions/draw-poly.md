**DrawPoly**

> `raylib.h` — módulo `rshapes`

O `DrawPoly` desenha um polígono regular preenchido: todos os lados com o mesmo tamanho, distribuídos ao redor de um centro

```c
void DrawPoly(Vector2 center, int sides, float radius, float rotation, Color color);
```

- `center`: o centro do polígono
- `sides`: a quantidade de lados (`3` triângulo, `4` quadrado, `6` hexágono...)
- `radius`: a distância do centro até cada vértice
- `rotation`: rotação em graus
- `color`: a cor de preenchimento

- Não devolve nada
- Com rotação `0`, o primeiro vértice aponta para a direita

```c
DrawPoly((Vector2){ 200, 225 }, 3, 50, -90, RED);   // triângulo com a ponta para cima
DrawPoly((Vector2){ 400, 225 }, 4, 50, 45, BLUE);   // quadrado alinhado com os eixos
DrawPoly((Vector2){ 600, 225 }, 6, 50, 0, GREEN);   // hexágono
```

- O quadrado com rotação `0` aparece como um losango (vértice para a direita). Com `45` graus, os lados ficam alinhados com a tela

> O raio é até o vértice, e não até o meio do lado. Ver `../polygons.md` para a geometria e um exemplo de mapa hexagonal
