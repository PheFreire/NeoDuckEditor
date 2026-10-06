**ImageDrawCircle**

> `raylib.h` — módulo `rtextures`

O `ImageDrawCircle` desenha um círculo preenchido dentro de uma imagem na RAM

```c
void ImageDrawCircle(Image *dst, int centerX, int centerY, int radius, Color color);
```

- `dst`: ponteiro para a imagem (é modificada)
- `centerX`, `centerY`: o centro do círculo
- `radius`: o raio, em pixels (inteiro)
- `color`: a cor de preenchimento

- Não devolve nada
- As partes fora da imagem são ignoradas
- Versões: `ImageDrawCircleV` (centro em `Vector2`), `ImageDrawCircleLines` e `ImageDrawCircleLinesV` (só o contorno)

```c
// gerar a textura de uma partícula: círculo branco sobre fundo transparente
Image particula = GenImageColor(16, 16, BLANK);
ImageDrawCircle(&particula, 8, 8, 7, WHITE);
Texture2D t_particula = LoadTextureFromImage(particula);
UnloadImage(particula);

// desenhada depois com qualquer cor como tint
DrawTexture(t_particula, x, y, ORANGE);
```

> Uma forma branca gerada uma vez e desenhada com tint vira uma textura reutilizável para muitas cores. O raio é inteiro, então círculos pequenos ficam com bordas visivelmente "em degraus"
