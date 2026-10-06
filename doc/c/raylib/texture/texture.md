**texture**

> `raylib.h` — módulo `rtextures`

Uma `Texture2D` é uma imagem guardada na **memória da placa de vídeo (VRAM, GPU)**, pronta para ser desenhada. É a forma como sprites, fundos, tilesets e qualquer imagem aparecem na tela. O programa não acessa os pixels diretamente: só pede à GPU para desenhar a textura, o que é muito rápido

```c
typedef struct Texture {
  unsigned int id;   // identificador da textura no OpenGL
  int width;         // largura em pixels
  int height;        // altura em pixels
  int mipmaps;       // níveis de mipmap
  int format;        // formato dos pixels (PixelFormat)
} Texture;

typedef Texture Texture2D;
```

```c
InitWindow(800, 450, "texturas");                // a textura precisa do contexto OpenGL
Texture2D heroi = LoadTexture("heroi.png");      // disco → GPU

while (!WindowShouldClose()) {
  BeginDrawing();
  ClearBackground(RAYWHITE);
  DrawTexture(heroi, 100, 100, WHITE);           // desenha na posição (100, 100)
  EndDrawing();
}

UnloadTexture(heroi);                            // libera a VRAM
CloseWindow();
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| diferença entre `Image` e `Texture2D` | `image-vs-texture.md` |
| carregar texturas | `texture-loading.md` |
| desenhar texturas, recortes, rotação e escala | `texture-drawing.md` |
| filtro: suave ou pixelado | `texture-filtering.md` |
| repetição (wrap) | `texture-wrapping.md` |
| desenhar dentro de uma textura (render texture) | `render-texture.md` |

- Cada função tem sua nota em `functions/`

---

**O id da textura**

- A struct `Texture2D` não contém os pixels: só o `id` que o OpenGL usa para encontrá-los na GPU, mais o tamanho e o formato
- Por isso copiar uma `Texture2D` com `=` é seguro e barato: as duas cópias apontam para a mesma textura na GPU. Mas só uma delas deve ser liberada com `UnloadTexture`
- Uma textura com `id == 0` é inválida (o carregamento falhou). Confira com `IsTextureValid`

> Texturas só existem enquanto o contexto OpenGL existe: devem ser carregadas depois do `InitWindow` e liberadas antes do `CloseWindow` (ver `../concepts/resource-lifetime.md` e `../concepts/cpu-vs-gpu.md`)
