**UpdateTexture**

> `raylib.h` — módulo `rtextures`

O `UpdateTexture` substitui todos os pixels de uma textura na GPU por novos dados vindos da RAM. É a forma de mostrar pixels calculados pelo programa a cada frame: emuladores, simulações, vídeo, efeitos procedurais

```c
void UpdateTexture(Texture2D texture, const void *pixels);
```

- `texture`: a textura a atualizar
- `pixels`: os novos pixels, no mesmo formato e com o mesmo tamanho da textura (`width x height` pixels)

- Não devolve nada
- O tamanho e o formato da textura não mudam: os dados precisam corresponder exatamente a eles
- Para atualizar só uma região, use `UpdateTextureRec(texture, rec, pixels)`

```c
// simulação: cada pixel é calculado na CPU e enviado de uma vez
#define W 320
#define H 180
Color pixels[W * H];

Image img = GenImageColor(W, H, BLACK);   // R8G8B8A8, do mesmo formato do buffer
Texture2D tela = LoadTextureFromImage(img);
UnloadImage(img);

while (!WindowShouldClose()) {
  for (int y = 0; y < H; y++) {
    for (int x = 0; x < W; x++) {
      unsigned char v = (unsigned char)((x ^ y) + (int)(GetTime() * 60));
      pixels[y * W + x] = (Color){ v, v / 2, 255 - v, 255 };
    }
  }
  UpdateTexture(tela, pixels);   // uma única cópia para a GPU por frame

  BeginDrawing();
  DrawTextureEx(tela, (Vector2){ 0, 0 }, 0, 4.0f, WHITE);   // ampliada 4x
  EndDrawing();
}
```

---

**Armadilhas**

- Um buffer menor que `width x height x bytes_por_pixel` faz a função ler memória além do fim do array, causando lixo na textura ou crash
- O formato do buffer precisa ser o da textura. Um array de `Color` só serve para texturas `R8G8B8A8`

> Enviar uma textura inteira por frame é aceitável para resoluções pequenas e médias. Para efeitos em tela cheia, um shader faz o mesmo cálculo diretamente na GPU, sem nenhuma transferência (ver `../../shaders/shaders.md`)
