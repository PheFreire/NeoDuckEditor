**SetShaderValueV**

> `raylib.h` — módulo `rcore`

O `SetShaderValueV` envia um array de valores para um uniform declarado como array no shader

```c
void SetShaderValueV(Shader shader, int locIndex, const void *value, int uniformType, int count);
```

- `shader`: o shader
- `locIndex`: a location do array
- `value`: ponteiro para o primeiro elemento
- `uniformType`: o tipo de cada elemento (`SHADER_UNIFORM_FLOAT`, `SHADER_UNIFORM_VEC2`...)
- `count`: quantos elementos enviar

- Não devolve nada

```glsl
uniform vec2 luzes[8];   // posições de até 8 luzes
uniform int n_luzes;
```

```c
Vector2 posicoes[8];
int n = 0;
for (int i = 0; i < n_tochas && n < 8; i++) posicoes[n++] = tochas[i].pos;

SetShaderValueV(s, GetShaderLocation(s, "luzes"), posicoes, SHADER_UNIFORM_VEC2, n);
SetShaderValue(s, GetShaderLocation(s, "n_luzes"), &n, SHADER_UNIFORM_INT);
```

> O tamanho do array no shader é fixo na compilação (`luzes[8]`). Envie no máximo esse número de elementos e passe a quantidade real em um uniform separado, como o `n_luzes`, para o shader saber quantos usar
