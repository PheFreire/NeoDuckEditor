**UnloadImage**

> `raylib.h` — módulo `rtextures`

O `UnloadImage` libera da memória RAM os pixels de uma imagem carregada ou gerada pelo raylib. É o par obrigatório de toda função que devolve uma `Image` nova

```c
void UnloadImage(Image image);
```

- `image`: a imagem a liberar

- Não devolve nada
- Libera o bloco `image.data` com `free` (o `RL_FREE` do raylib)
- A variável continua existindo, mas o `data` dela passa a apontar para memória liberada. Não use a imagem depois

```c
Image img = LoadImage("fundo.png");
Texture2D fundo = LoadTextureFromImage(img);
UnloadImage(img);   // a textura já está na GPU: a cópia na RAM pode ir embora

// ...

UnloadTexture(fundo);   // a textura tem seu próprio Unload
```

---

**Quem precisa de UnloadImage**

| Precisa | Não precisa |
|---------|-------------|
| `LoadImage`, `LoadImageRaw`, `LoadImageFromMemory`, `LoadImageAnim` | uma `Image` montada à mão com um `data` que o programa controla |
| `LoadImageFromTexture`, `LoadImageFromScreen` | |
| `GenImage...` (todas) | |
| `ImageCopy`, `ImageFromImage`, `ImageText` | |

---

**Armadilhas**

- Liberar duas imagens que compartilham o mesmo `data` (uma foi atribuída à outra com `=`) causa double free. Use `ImageCopy` para cópias independentes (ver `../image-memory.md`)
- Liberar a imagem **não** libera a textura criada a partir dela. São dois recursos, em duas memórias diferentes, cada um com seu `Unload`

> O `UnloadImage` não precisa da janela nem do contexto OpenGL: é só um `free` na RAM. Por isso pode ser chamado em qualquer momento, inclusive depois do `CloseWindow`
