**SetShaderValue**

> `raylib.h` — módulo `rcore`

O `SetShaderValue` envia um valor do programa em C para um uniform do shader

```c
void SetShaderValue(Shader shader, int locIndex, const void *value, int uniformType);
```

- `shader`: o shader
- `locIndex`: a location do uniform (de `GetShaderLocation`)
- `value`: ponteiro para o valor
- `uniformType`: o tipo, que precisa bater com o declarado no GLSL: `SHADER_UNIFORM_FLOAT`, `SHADER_UNIFORM_VEC2`, `SHADER_UNIFORM_VEC3`, `SHADER_UNIFORM_VEC4`, `SHADER_UNIFORM_INT`...

- Não devolve nada
- O valor fica guardado no shader até ser alterado

```c
Shader onda = LoadShader(NULL, "onda.fs");
int loc_tempo = GetShaderLocation(onda, "tempo");
int loc_mouse = GetShaderLocation(onda, "mouse");

while (!WindowShouldClose()) {
  float t = (float)GetTime();
  Vector2 m = GetMousePosition();
  SetShaderValue(onda, loc_tempo, &t, SHADER_UNIFORM_FLOAT);
  SetShaderValue(onda, loc_mouse, &m, SHADER_UNIFORM_VEC2);   // Vector2 tem 2 floats seguidos

  BeginDrawing();
  BeginShaderMode(onda);
    DrawTexture(agua, 0, 0, WHITE);
  EndShaderMode();
  EndDrawing();
}
```

> O parâmetro é um ponteiro (`&t`), mesmo para um único `float`. Structs como `Vector2`, `Vector3` e `Color` convertida para `Vector4` podem ser passadas direto, pois são floats contíguos na memória. Ver os tipos em `../uniforms.md`
