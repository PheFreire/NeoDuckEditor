**Ciclo de vida dos recursos**

> `Load...` e `Unload...` no raylib

Recursos são dados carregados pelo programa que ocupam memória: imagens, texturas, sons, músicas, fontes, shaders, modelos. No raylib, cada recurso é criado por uma função `Load...` (ou `Gen...`) e precisa ser destruído pela função `Unload...` correspondente. O raylib não tem coleta de lixo: o que é carregado e não liberado fica ocupando memória até o processo terminar

```c
Texture2D t = LoadTexture("heroi.png");   // cria
/* usa */
UnloadTexture(t);                          // destrói
```

---

**Pares Load / Unload**

| Recurso | Cria | Libera | Memória |
|---------|------|--------|---------|
| `Image` | `LoadImage`, `GenImage...`, `ImageCopy` | `UnloadImage` | RAM |
| `Texture2D` | `LoadTexture`, `LoadTextureFromImage` | `UnloadTexture` | VRAM |
| `RenderTexture2D` | `LoadRenderTexture` | `UnloadRenderTexture` | VRAM |
| `Font` | `LoadFont`, `LoadFontEx` | `UnloadFont` | VRAM + RAM |
| `Shader` | `LoadShader` | `UnloadShader` | GPU |
| `Model` | `LoadModel`, `LoadModelFromMesh` | `UnloadModel` | RAM + VRAM |
| `Mesh` (fora de modelo) | `GenMesh...`, `UploadMesh` | `UnloadMesh` | RAM + VRAM |
| `ModelAnimation *` | `LoadModelAnimations` | `UnloadModelAnimations` | RAM |
| `Sound` | `LoadSound` | `UnloadSound` | RAM |
| `Music` | `LoadMusicStream` | `UnloadMusicStream` | RAM + arquivo aberto |
| dados de arquivo | `LoadFileData` / `LoadFileText` | `UnloadFileData` / `UnloadFileText` | RAM |

---

**A ordem no programa**

```text
InitWindow / InitAudioDevice        sistemas
    │
    ▼
Load...                              recursos (precisam dos sistemas)
    │
    ▼
game loop                            usa os recursos
    │
    ▼
Unload...                            recursos (ainda precisam dos sistemas)
    │
    ▼
CloseAudioDevice / CloseWindow       sistemas
```

- Recursos de GPU (texturas, fontes, shaders, modelos) precisam do contexto OpenGL: carregue depois do `InitWindow` e libere antes do `CloseWindow`
- Sons e músicas precisam do `InitAudioDevice` e devem ser liberados antes do `CloseAudioDevice`

---

**Erros comuns**

| Erro | Consequência |
|------|--------------|
| carregar dentro do game loop | carrega de novo a cada frame, a memória cresce até travar |
| esquecer o `Unload` ao trocar de fase | vazamento: a memória das fases anteriores nunca volta |
| liberar duas vezes (cópias da struct) | double free, crash |
| usar depois de liberar | lixo na tela, som corrompido ou crash |
| liberar depois do `CloseWindow` | o contexto já não existe, comportamento indefinido |

---

**Quem é dono de quê**

- `LoadModelFromMesh`: o modelo passa a ser dono da mesh. Não chame `UnloadMesh` nela
- `UnloadModel`: não libera texturas nem shaders dos materiais, que podem ser compartilhados
- `LoadSoundAlias`: o alias não é dono dos dados. Libere os aliases antes do som original
- `GetFontDefault`: pertence ao raylib, não chame `UnloadFont`

> Uma forma simples de manter a ordem é ter uma função `carregar()` e uma `descarregar()` por fase ou tela, com os `Unload` na ordem inversa dos `Load`. O mesmo vale para a memória alocada com `malloc` no próprio programa (ver `../../memory/free.md`)
