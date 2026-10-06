**GetShaderLocationAttrib**

> `raylib.h` — módulo `rcore`

O `GetShaderLocationAttrib` devolve a location de um **atributo de vértice** do shader (uma variável `in` do vertex shader), como a posição, a normal ou um dado extra por vértice

```c
int GetShaderLocationAttrib(Shader shader, const char *attribName);
```

- `shader`: o shader
- `attribName`: o nome do atributo, como declarado no vertex shader

- Devolve a location, ou `-1` se o atributo não existe ou não é usado

```c
// os atributos padrão já são encontrados no carregamento
Shader s = LoadShader("custom.vs", "custom.fs");
int loc_pos = GetShaderLocationAttrib(s, "vertexPosition");   // normalmente 0

// guardar a location de um atributo com nome próprio em locs
s.locs[SHADER_LOC_VERTEX_COLOR] = GetShaderLocationAttrib(s, "corVertice");
```

---

**Uniform vs atributo**

| | Uniform | Atributo |
|---|---|---|
| Valor | um para o desenho inteiro | um por vértice |
| Vem de | `SetShaderValue` no C | os arrays da mesh |
| Função | `GetShaderLocation` | `GetShaderLocationAttrib` |

> Raramente é necessário: com os nomes padrão (`vertexPosition`, `vertexTexCoord`, `vertexNormal`, `vertexColor`), o raylib encontra os atributos sozinho. Só shaders com nomes próprios para os atributos precisam ajustar `shader.locs` manualmente
