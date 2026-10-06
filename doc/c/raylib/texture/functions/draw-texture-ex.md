**DrawTextureEx**

> `raylib.h` — módulo `rtextures`

O `DrawTextureEx` desenha uma textura inteira com rotação e escala uniforme

```c
void DrawTextureEx(Texture2D texture, Vector2 position, float rotation, float scale, Color tint);
```

- `texture`: a textura a desenhar
- `position`: o canto superior esquerdo da textura (e o ponto em torno do qual ela gira)
- `rotation`: rotação em graus, no sentido horário
- `scale`: escala: `1.0` tamanho original, `2.0` o dobro
- `tint`: cor que multiplica os pixels

- Não devolve nada
- A rotação acontece em torno do **canto superior esquerdo**, e não do centro

```c
DrawTextureEx(heroi, pos, 0, 4.0f, WHITE);     // pixel art ampliada 4x
DrawTextureEx(icone, pos, 0, 0.5f, WHITE);     // metade do tamanho
DrawTextureEx(helice, pos, GetTime() * 360, 1.0f, WHITE);   // girando em torno do canto
```

---

**Girar em torno do centro**

```text
DrawTextureEx(rotação 45)        DrawTexturePro com origin no centro
gira em torno do canto           gira em torno do centro
  ●                                   ◇
   ╲◇                                (fica no lugar)
```

- Para girar em torno do centro (o que quase sempre se quer em sprites), use o `DrawTexturePro` com `origin` igual à metade do tamanho de destino (ver `draw-texture-pro.md`)

> A escala é uniforme (a mesma em `x` e `y`). Para esticar em uma só direção ou desenhar com um tamanho exato, também use o `DrawTexturePro`
