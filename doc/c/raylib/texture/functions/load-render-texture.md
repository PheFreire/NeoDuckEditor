**LoadRenderTexture**

> `raylib.h` — módulo `rtextures`

O `LoadRenderTexture` cria uma render texture: uma textura vazia em que se pode desenhar, como uma tela extra. Internamente, cria um framebuffer do OpenGL com uma textura de cor e um buffer de profundidade

```c
RenderTexture2D LoadRenderTexture(int width, int height);
```

- `width`, `height`: o tamanho da textura, em pixels

- Devolve uma `RenderTexture2D` com:
    - `id`: o framebuffer (FBO)
    - `texture`: a textura de cor, que é desenhada depois com as funções `DrawTexture...`
    - `depth`: o buffer de profundidade, usado ao desenhar em 3D dentro dela
- Se falhar (tamanho grande demais para a GPU), escreve um aviso no log. Confira com `IsRenderTextureValid`
- Precisa da janela criada

```c
RenderTexture2D minimapa = LoadRenderTexture(200, 150);

BeginTextureMode(minimapa);
  ClearBackground(DARKGRAY);
  BeginMode2D(camera_minimapa);
    desenhar_mapa();
  EndMode2D();
EndTextureMode();

BeginDrawing();
  /* ... cena principal ... */
  DrawTextureRec(minimapa.texture, (Rectangle){ 0, 0, 200, -150 },   // altura negativa: desvira
                 (Vector2){ GetScreenWidth() - 210, 10 }, WHITE);
EndDrawing();
```

> O conteúdo de uma render texture fica de cabeça para baixo quando desenhado diretamente, por causa da origem das texturas no OpenGL. Use a altura negativa no retângulo de origem para desvirar (ver `../render-texture.md`)
