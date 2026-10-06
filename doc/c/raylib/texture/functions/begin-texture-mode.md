**BeginTextureMode**

> `raylib.h` — módulo `rcore`

O `BeginTextureMode` redireciona todo o desenho para uma render texture, em vez da tela. Até o `EndTextureMode`, as funções `Draw...` desenham dentro da textura

```c
void BeginTextureMode(RenderTexture2D target);
```

- `target`: a render texture que vai receber o desenho

- Não devolve nada
- Envia à GPU o que estava acumulado, troca o framebuffer ativo para o da textura e ajusta a área de desenho ao tamanho dela
- Pode ser usado **fora** do `BeginDrawing`, pois não desenha na tela

```c
RenderTexture2D alvo = LoadRenderTexture(320, 180);

while (!WindowShouldClose()) {
  BeginTextureMode(alvo);
    ClearBackground(BLACK);
    BeginMode2D(camera);
      desenhar_jogo();
    EndMode2D();
  EndTextureMode();

  BeginDrawing();
    DrawTexturePro(alvo.texture, (Rectangle){ 0, 0, 320, -180 },
                   (Rectangle){ 0, 0, GetScreenWidth(), GetScreenHeight() },
                   (Vector2){ 0 }, 0, WHITE);
  EndDrawing();
}
```

---

**Dentro do bloco**

- As coordenadas vão de `(0, 0)` a `(target.texture.width, target.texture.height)`
- `ClearBackground` limpa a textura, e não a tela
- `BeginMode2D`, `BeginMode3D`, `BeginShaderMode` e `BeginScissorMode` podem ser usados dentro
- `GetScreenWidth()` continua devolvendo o tamanho da **janela**: use o tamanho da textura para posicionar elementos

> Não aninhe dois `BeginTextureMode`: o segundo substitui o primeiro, e o `EndTextureMode` volta direto para a tela. Para desenhar em várias render textures, feche uma antes de abrir a outra (ver `../render-texture.md`)
