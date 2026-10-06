**UnloadFont**

> `raylib.h` — módulo `rtext`

O `UnloadFont` libera uma fonte carregada: a textura do atlas na GPU e as tabelas de caracteres na RAM

```c
void UnloadFont(Font font);
```

- `font`: a fonte a liberar

- Não devolve nada
- Deve ser chamado antes do `CloseWindow`, pois a fonte contém uma textura
- Não chame com a fonte padrão (`GetFontDefault`): ela é liberada pelo próprio raylib

```c
Font fonte = LoadFontEx("Inter.ttf", 24, NULL, 0);

while (!WindowShouldClose()) {
  /* ... */
}

UnloadFont(fonte);
CloseWindow();
```

> Uma `Font` guarda duas memórias: a textura na VRAM e os arrays `recs` e `glyphs` na RAM. O `UnloadFont` libera as duas. Liberar só a textura com `UnloadTexture(fonte.texture)` deixaria os arrays vazando (ver `../../concepts/resource-lifetime.md`)
