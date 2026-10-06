**IsCursorHidden**

> `raylib.h` — módulo `rcore`

O `IsCursorHidden` verifica se o cursor do mouse está invisível, seja por `HideCursor` ou por `DisableCursor`

```c
bool IsCursorHidden(void);
```

- Devolve `true` se o cursor está escondido ou desabilitado, e `false` se está visível

```c
if (IsKeyPressed(KEY_TAB)) {
  if (IsCursorHidden()) EnableCursor();   // libera o mouse para o menu
  else DisableCursor();                    // trava para controlar a câmera
}
```

> O `IsCursorHidden` não diferencia "escondido" de "desabilitado": os dois devolvem `true`. Se o programa usa os dois modos, guarde o modo atual em uma variável própria
