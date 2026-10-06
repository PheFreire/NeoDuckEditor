**Uniforms**

> `raylib.h` — módulo `rcore`

Um uniform é uma variável do shader cujo valor é enviado pelo programa em C e é o mesmo para todos os vértices e pixels de um desenho. É a forma de passar dados do jogo para o shader: tempo, posição do mouse, cor de um efeito, intensidade, resolução da tela

```glsl
uniform float tempo;        // GLSL
uniform vec2 resolucao;
uniform vec3 cor_luz;
```

```c
int loc_tempo = GetShaderLocation(s, "tempo");
int loc_res   = GetShaderLocation(s, "resolucao");
int loc_cor   = GetShaderLocation(s, "cor_luz");

float tempo = (float)GetTime();
float resolucao[2] = { (float)GetScreenWidth(), (float)GetScreenHeight() };
float cor[3] = { 1.0f, 0.8f, 0.5f };

SetShaderValue(s, loc_tempo, &tempo, SHADER_UNIFORM_FLOAT);
SetShaderValue(s, loc_res, resolucao, SHADER_UNIFORM_VEC2);
SetShaderValue(s, loc_cor, cor, SHADER_UNIFORM_VEC3);
```

---

**Tipos**

| Constante | GLSL | C |
|-----------|------|---|
| `SHADER_UNIFORM_FLOAT` | `float` | `float` |
| `SHADER_UNIFORM_VEC2` | `vec2` | `float[2]` ou `Vector2` |
| `SHADER_UNIFORM_VEC3` | `vec3` | `float[3]` ou `Vector3` |
| `SHADER_UNIFORM_VEC4` | `vec4` | `float[4]` ou `Vector4` |
| `SHADER_UNIFORM_INT` | `int` | `int` |
| `SHADER_UNIFORM_IVEC2` / `IVEC3` / `IVEC4` | `ivec2` / ... | `int[n]` |
| `SHADER_UNIFORM_SAMPLER2D` | `sampler2D` | use `SetShaderValueTexture` |

- Matrizes (`mat4`) são enviadas com `SetShaderValueMatrix`
- Arrays (`uniform float pesos[8];`) com `SetShaderValueV`, passando a quantidade

---

**Funções**

| Função | Envia |
|--------|-------|
| `SetShaderValue(s, loc, &valor, tipo)` | um valor |
| `SetShaderValueV(s, loc, array, tipo, n)` | um array de `n` valores |
| `SetShaderValueMatrix(s, loc, matriz)` | uma matriz 4x4 |
| `SetShaderValueTexture(s, loc, textura)` | uma textura para um `sampler2D` |

---

**O valor fica guardado**

- O uniform mantém o último valor enviado até receber outro. Valores que não mudam (resolução, cor fixa) podem ser enviados uma vez, depois de carregar o shader
- Valores que mudam (tempo, posição do mouse) são enviados a cada frame, antes do `BeginShaderMode`

> O tipo passado precisa corresponder ao tipo declarado no shader. Enviar um `vec3` para um `uniform vec2` ou um `int` para um `float` não gera erro no C, mas o valor chega errado ou é ignorado pela GPU
