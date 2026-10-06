**LoadTexture**

> `raylib.h` — módulo `rtextures`

O `LoadTexture` lê um arquivo de imagem e o carrega direto na memória da placa de vídeo (VRAM) como uma `Texture2D`, pronta para ser desenhada

```c
Texture2D LoadTexture(const char *fileName);
```

- `fileName`: o caminho do arquivo de imagem, relativo ao diretório de trabalho ou absoluto

- Devolve a `Texture2D` carregada
- Se falhar, escreve um aviso no log e devolve uma textura com `id == 0`. Confira com `IsTextureValid`
- Precisa da janela criada: chamar antes do `InitWindow` falha, pois o contexto OpenGL ainda não existe

```c
InitWindow(800, 450, "jogo");

Texture2D heroi = LoadTexture("assets/heroi.png");
Texture2D fundo = LoadTexture("assets/fundo.png");

while (!WindowShouldClose()) {
  BeginDrawing();
  DrawTexture(fundo, 0, 0, WHITE);
  DrawTextureV(heroi, pos, WHITE);
  EndDrawing();
}

UnloadTexture(fundo);
UnloadTexture(heroi);
CloseWindow();
```

> Internamente, faz `LoadImage`, `LoadTextureFromImage` e `UnloadImage` em sequência. Se a imagem precisar de alguma edição antes (redimensionar, recortar, mudar cores), faça esses três passos manualmente (ver `load-texture-from-image.md` e `../texture-loading.md`)
