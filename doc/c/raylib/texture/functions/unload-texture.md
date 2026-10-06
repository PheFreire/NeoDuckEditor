**UnloadTexture**

> `raylib.h` — módulo `rtextures`

O `UnloadTexture` libera uma textura da memória da placa de vídeo. É o par obrigatório do `LoadTexture` e do `LoadTextureFromImage`

```c
void UnloadTexture(Texture2D texture);
```

- `texture`: a textura a liberar

- Não devolve nada
- Apaga a textura na GPU (`glDeleteTextures`) usando o `id`
- Deve ser chamado **antes** do `CloseWindow`, enquanto o contexto OpenGL existe

```c
Texture2D t = LoadTexture("heroi.png");
/* ... */
UnloadTexture(t);
CloseWindow();
```

---

**Trocando de textura durante o jogo**

```c
// mudar de fase: libera a textura antiga antes de carregar a nova
UnloadTexture(mapa_atual);
mapa_atual = LoadTexture(TextFormat("fase%d.png", fase));
```

- Sem o `UnloadTexture`, cada troca de fase deixa a textura antiga ocupando a VRAM até o fim do programa (vazamento de memória de vídeo)

---

**Armadilhas**

- Copiar uma `Texture2D` com `=` copia só o `id`. Liberar as duas cópias tenta apagar a mesma textura duas vezes
- Desenhar uma textura depois de liberada não mostra nada, ou mostra outra textura que reaproveitou o mesmo `id`
- Render textures são liberadas com `UnloadRenderTexture`, e não com `UnloadTexture` (ver `unload-render-texture.md`)

> Liberar uma textura não afeta a `Image` de onde ela veio, e vice-versa: cada uma está em uma memória diferente e tem o seu próprio `Unload` (ver `../../concepts/resource-lifetime.md`)
