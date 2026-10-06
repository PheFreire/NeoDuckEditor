**UnloadShader**

> `raylib.h` — módulo `rcore`

O `UnloadShader` apaga o programa do shader da GPU e libera o array de locations

```c
void UnloadShader(Shader shader);
```

- `shader`: o shader a liberar

- Não devolve nada
- Deve ser chamado antes do `CloseWindow`
- Não libera o shader padrão do raylib, mesmo que ele seja passado

```c
Shader s = LoadShader(NULL, "efeito.fs");
/* ... */
UnloadShader(s);
CloseWindow();
```

> Shaders atribuídos a materiais de modelos não são liberados pelo `UnloadModel`: libere com `UnloadShader` depois que nenhum modelo o usar mais (ver `../../models/functions/unload-model.md`)
