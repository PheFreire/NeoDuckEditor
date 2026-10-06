**DrawTextureV**

> `raylib.h` — módulo `rtextures`

O `DrawTextureV` desenha uma textura inteira, no tamanho original, com a posição dada como `Vector2`. É a versão do `DrawTexture` para posições em ponto flutuante

```c
void DrawTextureV(Texture2D texture, Vector2 position, Color tint);
```

- `texture`: a textura a desenhar
- `position`: o canto superior esquerdo
- `tint`: cor que multiplica os pixels

- Não devolve nada

```c
Vector2 pos = { 100, 300 };
Vector2 vel = { 120, 0 };

pos = Vector2Add(pos, Vector2Scale(vel, GetFrameTime()));
DrawTextureV(heroi, pos, WHITE);
```

> Com a posição em `float`, um objeto lento se move de forma suave, sem o arredondamento para `int` a cada frame. Para pixel art, onde cada pixel precisa cair exatamente na grade, arredonde a posição antes de desenhar (`floorf`), ou os sprites podem parecer tremer
