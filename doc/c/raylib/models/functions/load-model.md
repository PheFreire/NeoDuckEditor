**LoadModel**

> `raylib.h` — módulo `rmodels`

O `LoadModel` carrega um modelo 3D de um arquivo: as meshes (geometria), os materiais e, quando o formato tem, o esqueleto para animação. A geometria é enviada para a GPU e as texturas dos materiais são carregadas

```c
Model LoadModel(const char *fileName);
```

- `fileName`: o arquivo do modelo (`.obj`, `.gltf`, `.glb`, `.iqm`, `.vox`, `.m3d`)

- Devolve o `Model` carregado
- Precisa da janela criada (usa a GPU)
- Se falhar, escreve um aviso no log e devolve um modelo com um cubo padrão no lugar das meshes. Confira com `IsModelValid`
- As texturas referenciadas pelo arquivo são procuradas a partir da pasta do modelo

```c
Model arvore = LoadModel("modelos/arvore.glb");

BeginMode3D(camera);
  DrawModel(arvore, (Vector3){ 0, 0, 0 }, 1.0f, WHITE);
EndMode3D();

UnloadModel(arvore);
```

---

**Exportando do Blender**

- Prefira glTF binário (`.glb`): um único arquivo com geometria, materiais, texturas e animações
- O Blender usa `z` para cima, e o raylib usa `y` para cima. O exportador glTF converte automaticamente ("+Y Up")
- Aplique a escala e a rotação no Blender antes de exportar (Apply → All Transforms), ou o modelo pode aparecer girado ou com o tamanho errado

> O `UnloadModel` libera as meshes, mas não as texturas dos materiais, que podem ser compartilhadas. Para modelos carregados de arquivo, libere as texturas com `UnloadTexture` antes do `UnloadModel` se elas não forem usadas por outros modelos (ver `unload-model.md`)
