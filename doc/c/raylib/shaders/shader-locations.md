**Locations**

> `raylib.h` — tipo `Shader`

Uma location é o número que a GPU usa para identificar uma variável de um shader (um `uniform` ou um atributo de vértice). O programa em C não acessa as variáveis do shader pelo nome: primeiro descobre a location, e depois envia valores para ela

```c
typedef struct Shader {
  unsigned int id;   // programa na GPU
  int *locs;         // locations das variáveis padrão, indexadas por SHADER_LOC_*
} Shader;

int GetShaderLocation(Shader shader, const char *uniformName);
int GetShaderLocationAttrib(Shader shader, const char *attribName);
```

```c
Shader s = LoadShader(NULL, "onda.fs");
int loc_tempo = GetShaderLocation(s, "tempo");   // procure uma vez, depois de carregar

while (!WindowShouldClose()) {
  float t = (float)GetTime();
  SetShaderValue(s, loc_tempo, &t, SHADER_UNIFORM_FLOAT);   // envia usando a location
  /* ... */
}
```

---

**Locations padrão (shader.locs)**

Ao carregar o shader, o raylib procura as variáveis com os nomes padrão e guarda as locations em `shader.locs`:

| Índice em `locs` | Nome procurado no shader | Tipo |
|------------------|--------------------------|------|
| `SHADER_LOC_VERTEX_POSITION` | `vertexPosition` | atributo |
| `SHADER_LOC_VERTEX_TEXCOORD01` | `vertexTexCoord` | atributo |
| `SHADER_LOC_VERTEX_NORMAL` | `vertexNormal` | atributo |
| `SHADER_LOC_VERTEX_COLOR` | `vertexColor` | atributo |
| `SHADER_LOC_MATRIX_MVP` | `mvp` | uniform |
| `SHADER_LOC_MATRIX_VIEW` / `PROJECTION` / `MODEL` / `NORMAL` | `matView`, `matProjection`, `matModel`, `matNormal` | uniform |
| `SHADER_LOC_COLOR_DIFFUSE` | `colDiffuse` | uniform |
| `SHADER_LOC_MAP_DIFFUSE` | `texture0` | uniform (textura) |

- O raylib preenche esses valores automaticamente a cada desenho: a matriz `mvp`, a cor do tint em `colDiffuse`, a textura em `texture0`
- Um shader que usa esses nomes funciona com `DrawTexture`, `DrawModel` e afins sem nenhuma configuração

---

**Location -1**

- `GetShaderLocation` devolve `-1` se a variável não existe no shader
- O compilador GLSL **remove** variáveis declaradas e não usadas. Um `uniform float tempo;` que nunca é lido no `main` não tem location, e a função devolve `-1`
- Enviar valores para a location `-1` é ignorado em silêncio, então um efeito que "não funciona" pode ser só uma variável otimizada pelo compilador

> Busque as locations uma vez, logo depois do `LoadShader`, e guarde em variáveis. Procurar pelo nome todo frame funciona, mas faz uma busca de string desnecessária a cada chamada (ver `uniforms.md`)
