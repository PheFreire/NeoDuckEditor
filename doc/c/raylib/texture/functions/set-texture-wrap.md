**SetTextureWrap**

> `raylib.h` — módulo `rtextures`

O `SetTextureWrap` define o que a GPU desenha quando a textura é lida fora dos seus limites: repetir, espelhar ou esticar a borda

```c
void SetTextureWrap(Texture2D texture, int wrap);
```

- `texture`: a textura
- `wrap`: o modo:
    - `TEXTURE_WRAP_REPEAT`: repete como azulejo (padrão)
    - `TEXTURE_WRAP_CLAMP`: estica o pixel da borda
    - `TEXTURE_WRAP_MIRROR_REPEAT`: repete espelhando a cada vez
    - `TEXTURE_WRAP_MIRROR_CLAMP`: espelha uma vez e prende na borda

- Não devolve nada
- O modo fica gravado na textura

```c
Texture2D tijolo = LoadTexture("tijolo_32.png");
SetTextureWrap(tijolo, TEXTURE_WRAP_REPEAT);

// parede de 320x96 coberta com tijolos de 32x32
DrawTexturePro(tijolo, (Rectangle){ 0, 0, 320, 96 }, (Rectangle){ 100, 200, 320, 96 },
               (Vector2){ 0, 0 }, 0, WHITE);
```

> A repetição só acontece quando o retângulo de origem é maior que a textura (ou, em 3D, quando as coordenadas de textura do modelo passam de `1`). Ver `../texture-wrapping.md` para o fundo com rolagem
