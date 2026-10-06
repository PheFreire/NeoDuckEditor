**UnloadMaterial**

> `raylib.h` — módulo `rmodels`

O `UnloadMaterial` libera um material: o shader (se não for o padrão), as texturas dos maps (se não forem a textura padrão) e o array de maps

```c
void UnloadMaterial(Material material);
```

- `material`: o material a liberar

- Não devolve nada
- Diferente do `UnloadModel`, **libera** as texturas e o shader do material
- Deve ser chamado antes do `CloseWindow`

```c
Material mat = LoadMaterialDefault();
mat.maps[MATERIAL_MAP_DIFFUSE].texture = LoadTexture("pedra.png");

/* desenhar com DrawMesh(mesh, mat, matriz) */

UnloadMaterial(mat);   // libera a textura de pedra junto
```

> Como libera as texturas, o `UnloadMaterial` não deve ser usado em um material cujas texturas estão compartilhadas com outros materiais ou modelos ainda em uso. Nesses casos, libere as texturas manualmente, uma única vez, no final
