**Render texture**

> `raylib.h` — módulo `rtextures`

Uma render texture é uma textura em que se pode **desenhar**, como se fosse uma segunda tela. Tudo que é desenhado entre `BeginTextureMode` e `EndTextureMode` vai para ela em vez de ir para a janela, e depois ela pode ser desenhada como qualquer textura. É a base de efeitos de pós-processamento, escala de pixel art, minimapas, espelhos e telas divididas

```c
typedef struct RenderTexture {
  unsigned int id;     // framebuffer (FBO) no OpenGL
  Texture texture;     // a textura de cor, onde o desenho fica
  Texture depth;       // o buffer de profundidade (para 3D)
} RenderTexture;

typedef RenderTexture RenderTexture2D;
```

```c
RenderTexture2D alvo = LoadRenderTexture(320, 180);   // resolução interna baixa

while (!WindowShouldClose()) {
  BeginTextureMode(alvo);                // desenhar na textura
    ClearBackground(SKYBLUE);
    desenhar_jogo();                     // em coordenadas de 320x180
  EndTextureMode();

  BeginDrawing();                        // desenhar na tela
    ClearBackground(BLACK);
    DrawTexturePro(alvo.texture,
      (Rectangle){ 0, 0, alvo.texture.width, -alvo.texture.height },   // altura negativa: desvira
      (Rectangle){ 0, 0, GetScreenWidth(), GetScreenHeight() },        // ampliada para a janela
      (Vector2){ 0, 0 }, 0, WHITE);
  EndDrawing();
}

UnloadRenderTexture(alvo);
```

---

**Por que a textura aparece de cabeça para baixo**

```text
tela / imagens:   (0,0) no canto SUPERIOR esquerdo, y para baixo
OpenGL texturas:  (0,0) no canto INFERIOR esquerdo, y para cima
```

- O conteúdo de uma render texture fica invertido na vertical quando desenhado diretamente
- A correção padrão é usar a altura **negativa** no retângulo de origem: `(Rectangle){ 0, 0, w, -h }`

---

**Usos**

| Uso | Como |
|-----|------|
| pixel art em qualquer resolução | desenhar em 320x180 e ampliar com filtro point |
| pós-processamento (blur, CRT, cores) | desenhar a cena na textura e depois desenhá-la com um shader |
| minimapa, retrovisor, câmera de segurança | desenhar a cena com outra câmera na textura e mostrar pequena |
| tela dividida | uma render texture por jogador, cada uma com sua câmera |
| pintura persistente | não limpar a textura entre frames, acumulando o desenho |

---

**Armadilhas**

- O `BeginTextureMode` usa o tamanho da render texture como "tela": `GetScreenWidth()` continua devolvendo o tamanho da janela, e não o da textura. Use `alvo.texture.width` dentro do bloco
- Ao mudar o tamanho da janela, render textures do tamanho da tela precisam ser recriadas (ver `../core/functions/is-window-resized.md`)
- Liberar com `UnloadRenderTexture`, e não com `UnloadTexture`, que liberaria só a textura de cor e deixaria o framebuffer

> Pode-se desenhar em uma render texture fora do `BeginDrawing`, pois ela é independente da tela. Mas não aninhe dois `BeginTextureMode`: termine um antes de começar outro
