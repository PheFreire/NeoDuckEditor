**UnloadModelAnimation**

> `raylib.h` — módulo `rmodels`

O `UnloadModelAnimation` libera os dados de uma única animação: as poses de cada frame e as informações dos ossos

```c
void UnloadModelAnimation(ModelAnimation anim);
```

- `anim`: a animação a liberar

- Não devolve nada
- Libera os dados internos da animação, mas **não** o array devolvido pelo `LoadModelAnimations`

```c
int n = 0;
ModelAnimation *anims = LoadModelAnimations("heroi.glb", &n);

/* ... */

// forma mais simples: libera todas as animações e o array de uma vez
UnloadModelAnimations(anims, n);
```

---

**Uma ou todas**

| Função | Libera |
|--------|--------|
| `UnloadModelAnimation(anim)` | os dados de uma animação |
| `UnloadModelAnimations(array, n)` | os dados de todas as `n` animações e o próprio array |

- Para animações carregadas com `LoadModelAnimations`, use sempre o `UnloadModelAnimations` (no plural), que também libera o array

> As animações são independentes do modelo: o `UnloadModel` não as libera, e elas podem ser liberadas antes ou depois dele (ver `../animations.md`)
