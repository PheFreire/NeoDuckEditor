**Desenhando em imagens**

> `raylib.h` — módulo `rtextures`

As funções `ImageDraw...` desenham formas, texto e outras imagens **dentro** de uma `Image`, na RAM, pela CPU. Diferente das funções `Draw...`, elas não aparecem na tela: alteram os pixels da imagem, que depois pode ser salva em arquivo ou enviada para a GPU como textura

| Função | Desenha na imagem |
|--------|-------------------|
| `ImageClearBackground(&img, cor)` | preenche a imagem toda |
| `ImageDrawPixel(&img, x, y, cor)` | um pixel |
| `ImageDrawLine(&img, x1, y1, x2, y2, cor)` | uma linha |
| `ImageDrawCircle(&img, cx, cy, raio, cor)` | um círculo preenchido |
| `ImageDrawRectangle(&img, x, y, w, h, cor)` | um retângulo preenchido |
| `ImageDrawTriangle(&img, v1, v2, v3, cor)` | um triângulo |
| `ImageDraw(&dst, src, srcRec, dstRec, tint)` | outra imagem (ou um pedaço dela) |
| `ImageDrawText(&img, texto, x, y, tamanho, cor)` | texto com a fonte padrão |

```c
Image mapa = GenImageColor(256, 256, DARKGREEN);
ImageDrawRectangle(&mapa, 20, 20, 60, 40, BROWN);     // casa
ImageDrawCircle(&mapa, 180, 120, 30, BLUE);           // lago
ImageDrawLine(&mapa, 0, 200, 256, 200, GRAY);         // estrada
ImageDrawText(&mapa, "vila", 25, 65, 10, WHITE);

ExportImage(mapa, "mapa.png");                        // salvar em arquivo
Texture2D t = LoadTextureFromImage(mapa);             // ou usar no jogo
UnloadImage(mapa);
```

---

**ImageDraw... vs Draw...**

| | `ImageDraw...` | `Draw...` |
|---|---|---|
| Onde desenha | na RAM, dentro de uma `Image` | na tela (ou render texture), pela GPU |
| Quem faz o trabalho | a CPU, pixel por pixel | a GPU |
| Velocidade | lenta para áreas grandes | rápida |
| Resultado | pixels que podem ser lidos e salvos | aparece na tela, não é acessível |
| Quando usar | gerar imagens uma vez, exportar, texturas procedurais | desenhar a cada frame |

- Desenhar com `ImageDraw...` a cada frame e recriar a textura é muito lento. Para desenhar em uma textura todo frame, use uma render texture com as funções `Draw...` normais (ver `../texture/render-texture.md`)

> Os parâmetros das funções `ImageDraw...` usam as mesmas coordenadas das funções de tela: `(0, 0)` no canto superior esquerdo da imagem, com `y` crescendo para baixo. Desenhos fora dos limites da imagem são cortados
