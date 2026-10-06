**UnloadModel**

> `raylib.h` — módulo `rmodels`

O `UnloadModel` libera um modelo: as meshes (na RAM e na GPU), o array de materiais e os dados de esqueleto

```c
void UnloadModel(Model model);
```

- `model`: o modelo a liberar

- Não devolve nada
- Libera todas as meshes do modelo
- Libera os arrays de maps dos materiais, mas **não** as texturas nem os shaders usados por eles, que podem estar compartilhados com outros modelos
- Deve ser chamado antes do `CloseWindow`

```c
Model nave = LoadModel("nave.glb");
Shader brilho = LoadShader(NULL, "brilho.fs");
nave.materials[0].shader = brilho;

/* ... */

UnloadModel(nave);
UnloadShader(brilho);   // o shader é responsabilidade do programa
```

---

**O que é liberado**

| Recurso | `UnloadModel` libera? |
|---------|-----------------------|
| meshes (vértices na RAM e buffers na GPU) | sim |
| array `materials` e os `maps` | sim |
| texturas dos materiais | não |
| shaders dos materiais | não |
| animações (`ModelAnimation`) | não: `UnloadModelAnimations` |

> Texturas carregadas automaticamente pelo `LoadModel` (do `.mtl` ou do `.glb`) ficam ocupando a VRAM se não forem liberadas. Antes do `UnloadModel`, percorra os materiais e libere as texturas que só esse modelo usa (ver `../materials.md`)
