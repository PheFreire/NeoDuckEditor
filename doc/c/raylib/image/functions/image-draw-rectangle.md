**ImageDrawRectangle**

> `raylib.h` — módulo `rtextures`

O `ImageDrawRectangle` desenha um retângulo preenchido dentro de uma imagem na RAM

```c
void ImageDrawRectangle(Image *dst, int posX, int posY, int width, int height, Color color);
```

- `dst`: ponteiro para a imagem (é modificada)
- `posX`, `posY`: o canto superior esquerdo
- `width`, `height`: o tamanho
- `color`: a cor de preenchimento

- Não devolve nada
- As partes fora da imagem são ignoradas
- Versões: `ImageDrawRectangleV` (com `Vector2`), `ImageDrawRectangleRec` (com `Rectangle`) e `ImageDrawRectangleLines` (contorno com espessura)

```c
// gerar uma textura de botão com borda
Image botao = GenImageColor(200, 60, DARKBLUE);
ImageDrawRectangle(&botao, 4, 4, 192, 52, SKYBLUE);              // fundo dentro da borda
ImageDrawText(&botao, "JOGAR", 60, 18, 24, DARKBLUE);
Texture2D t_botao = LoadTextureFromImage(botao);
UnloadImage(botao);
```

> Para texturas de interface que precisam esticar sem deformar a borda (botões e painéis de tamanhos variados), o raylib tem o `DrawTextureNPatch`, que divide a textura em 9 partes e estica só o centro
