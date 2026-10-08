**ImageFromImage**

> `raylib.h` — módulo `rtextures`

O `ImageFromImage` cria uma imagem nova a partir de um pedaço retangular de outra. A imagem original não é alterada. É a forma direta de cortar uma sprite sheet: cada chamada copia uma célula da folha para uma `Image` independente

```c
Image ImageFromImage(Image image, Rectangle rec);
```

- `image`: a imagem de origem (só é lida, por isso é passada por valor)
- `rec`: a região a copiar, em pixels, com `x`, `y` (canto superior esquerdo), `width` e `height`

- Devolve uma nova `Image` do tamanho de `rec`, no mesmo formato da original, em um bloco de memória separado
- A imagem devolvida precisa do seu próprio `UnloadImage`
- O retângulo **não** é ajustado aos limites da imagem: ele deve estar inteiro dentro dela

```c
// pegar o sprite de 32x32 da terceira célula da primeira linha
Image folha = LoadImage("personagens.png");
Image heroi = ImageFromImage(folha, (Rectangle){ 64, 0, 32, 32 });

Texture2D t_heroi = LoadTextureFromImage(heroi);
UnloadImage(heroi);
UnloadImage(folha);
```

---

**Cortando uma sprite sheet inteira**

```text
andar.png (128x64, células de 32x32)

     x=0    x=32   x=64   x=96
y=0  ┌──────┬──────┬──────┬──────┐
     │  0   │  1   │  2   │  3   │   linha 0
y=32 ├──────┼──────┼──────┼──────┤
     │  4   │  5   │  6   │  7   │   linha 1
     └──────┴──────┴──────┴──────┘

célula i → x = (i % colunas) * largura
           y = (i / colunas) * altura
```

```c
#define LARGURA 32
#define ALTURA  32

Image folha = LoadImage("andar.png");
int colunas = folha.width / LARGURA;
int linhas  = folha.height / ALTURA;
int total   = colunas * linhas;

Texture2D frames[64];
for (int i = 0; i < total; i++) {
  Rectangle celula = {
    (float)((i % colunas) * LARGURA),
    (float)((i / colunas) * ALTURA),
    LARGURA, ALTURA
  };
  Image frame = ImageFromImage(folha, celula);
  frames[i] = LoadTextureFromImage(frame);
  UnloadImage(frame);               // o frame já está na GPU
}
UnloadImage(folha);

// ao encerrar
for (int i = 0; i < total; i++) UnloadTexture(frames[i]);
```

- `colunas` e `linhas` vêm do tamanho da folha, então a folha pode ganhar frames sem mudar o código. Pixels que sobram no fim (uma folha de 100 pixels com células de 32) são ignorados
- Cada recorte é liberado logo depois de virar textura, porque a `Image` só é necessária até o upload para a GPU (ver `../../texture/image-vs-texture.md`)
- O `Rectangle` usa `float`, por isso o cast nas contas com `int`

---

**Sprite sheet com margem e espaçamento**

```text
margem ┌─────────────────────────────┐
 2px   │  ┌────┐ 1px ┌────┐ 1px ┌────┐
       │  │ 0  │     │ 1  │     │ 2  │
       │  └────┘     └────┘     └────┘
```

```c
int margem = 2, espaco = 1;
Rectangle celula = {
  (float)(margem + coluna * (LARGURA + espaco)),
  (float)(margem + linha  * (ALTURA  + espaco)),
  LARGURA, ALTURA
};
```

- Muitas folhas deixam pixels entre as células para evitar que um sprite "vaze" para o vizinho ao desenhar com filtro bilinear (ver `../../texture/texture-wrapping.md`)

---

**ImageFromImage vs ImageCrop**

| | `ImageFromImage(img, rec)` | `ImageCrop(&img, rec)` |
|---|---|---|
| Original | intacta | substituída pelo recorte |
| Retorno | uma `Image` nova | nada |
| Vários recortes da mesma folha | chamadas seguidas na mesma folha | precisa de um `ImageCopy` antes de cada recorte |
| Retângulo fora da imagem | não é ajustado | ajustado para caber |

- Para cortar várias células, o `ImageFromImage` evita copiar a folha inteira a cada recorte (ver `image-crop.md`)

---

**Quando recortar e quando não recortar**

```c
// sem recorte: a folha inteira em uma textura, desenhando só a célula do frame atual
Texture2D folha = LoadTexture("andar.png");
Rectangle origem = { frame * 32, 0, 32, 32 };
DrawTextureRec(folha, origem, pos, WHITE);
```

- Para **desenhar** frames de animação, não é preciso recortar: uma única textura com `DrawTextureRec` ou `DrawTexturePro` é mais eficiente, porque a GPU não troca de textura entre os sprites (ver `../../texture/texture-drawing.md`)
- Recorte com `ImageFromImage` quando cada célula precisa ser tratada como uma imagem separada:
    - editar só um frame na CPU (espelhar, recolorir, redimensionar com `ImageResizeNN`)
    - exportar cada frame para um arquivo com `ExportImage`
    - usar um sprite como ícone da janela (`SetWindowIcon`)
    - ler os pixels de uma célula (`GetImageColor`, detecção de colisão por pixel)
    - montar um atlas novo com outra organização usando `ImageDraw`

> Um retângulo que passa dos limites da folha faz o `ImageFromImage` ler memória fora dos pixels da imagem, o que é comportamento indefinido e pode gerar lixo na imagem ou um crash. Confira `rec.x + rec.width <= image.width` e `rec.y + rec.height <= image.height`, ou calcule as células a partir do tamanho da folha como no exemplo acima
