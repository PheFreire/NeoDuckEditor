**DrawEllipse**

> `raylib.h` — módulo `rshapes`

O `DrawEllipse` desenha uma elipse preenchida, com um raio horizontal e um raio vertical diferentes. É um círculo "esticado" em uma das direções

```c
void DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, Color color);
```

- `centerX`, `centerY`: o centro da elipse
- `radiusH`: raio horizontal (metade da largura)
- `radiusV`: raio vertical (metade da altura)
- `color`: a cor de preenchimento

- Não devolve nada
- Com `radiusH == radiusV`, desenha um círculo
- Não tem parâmetro de rotação: os eixos da elipse são sempre horizontal e vertical
- O contorno é desenhado com `DrawEllipseLines`, com os mesmos parâmetros

```c
// sombra sob o personagem, achatada para parecer no chão
DrawEllipse((int)jogador.x, (int)jogador.y + 30, 20, 6, Fade(BLACK, 0.3f));
DrawCircleV(jogador, 16, BLUE);
```

> Para uma elipse rotacionada, desenhe em uma render texture e gire a textura com `DrawTexturePro`, ou monte os pontos manualmente e desenhe com `DrawTriangleFan`
