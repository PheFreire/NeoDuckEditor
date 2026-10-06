**ImageRotate**

> `raylib.h` — módulo `rtextures`

O `ImageRotate` gira os pixels de uma imagem por um ângulo em graus. A imagem resultante cresce para caber a figura girada, e as áreas novas ficam transparentes

```c
void ImageRotate(Image *image, int degrees);
```

- `image`: ponteiro para a imagem (é modificada)
- `degrees`: o ângulo, de `-359` a `359`. Positivo gira no sentido horário

- Não devolve nada
- Para ângulos que não são múltiplos de 90, a imagem fica maior, para não cortar os cantos
- Mesmo em 90 graus, o `ImageRotate` interpola os pixels e pode perder uma linha ou coluna na borda. Para giros de 90 graus exatos, existem `ImageRotateCW` (horário) e `ImageRotateCCW` (anti-horário), mais simples e sem perdas

```c
Image seta = LoadImage("seta.png");

Image cima     = ImageCopy(seta);
Image direita  = ImageCopy(seta); ImageRotateCW(&direita);
Image baixo    = ImageCopy(seta); ImageRotateCW(&baixo); ImageRotateCW(&baixo);   // 180 graus sem perdas
Image esquerda = ImageCopy(seta); ImageRotateCCW(&esquerda);
```

---

**Girar a imagem ou girar no desenho**

- `ImageRotate`: gira os pixels uma vez, na CPU. Útil para gerar variações que serão salvas ou usadas como texturas separadas
- `DrawTextureEx` / `DrawTexturePro` com `rotation`: gira na hora de desenhar, na GPU, sem custo extra. É o certo para objetos que giram continuamente

> Girar pixels em ângulos quebrados (como 30 graus) sempre perde um pouco de qualidade, pois cada pixel novo é calculado a partir dos antigos. Girar na GPU, a partir da textura original, mantém a qualidade em qualquer ângulo
