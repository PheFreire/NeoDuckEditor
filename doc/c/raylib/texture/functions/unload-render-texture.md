**UnloadRenderTexture**

> `raylib.h` — módulo `rtextures`

O `UnloadRenderTexture` libera uma render texture da memória da placa de vídeo: o framebuffer, a textura de cor e o buffer de profundidade

```c
void UnloadRenderTexture(RenderTexture2D target);
```

- `target`: a render texture a liberar

- Não devolve nada
- Deve ser chamado antes do `CloseWindow`

```c
RenderTexture2D tela = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());

while (!WindowShouldClose()) {
  if (IsWindowResized()) {
    UnloadRenderTexture(tela);   // a antiga tem o tamanho errado
    tela = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());
  }
  /* ... */
}

UnloadRenderTexture(tela);
CloseWindow();
```

> Usar `UnloadTexture(tela.texture)` libera só a textura de cor e deixa o framebuffer e o buffer de profundidade ocupando memória. Render textures sempre são liberadas com `UnloadRenderTexture`
