**LoadShaderFromMemory**

> `raylib.h` — módulo `rcore`

O `LoadShaderFromMemory` compila um shader a partir de strings com o código GLSL, em vez de arquivos. Permite embutir o shader no próprio código C, sem arquivos externos

```c
Shader LoadShaderFromMemory(const char *vsCode, const char *fsCode);
```

- `vsCode`: o código do vertex shader, ou `NULL` para o padrão
- `fsCode`: o código do fragment shader, ou `NULL` para o padrão

- Devolve o `Shader` compilado, ou um shader inválido se houver erro (detalhes no log)

```c
const char *fs_invertido =
  "#version 330\n"
  "in vec2 fragTexCoord;\n"
  "in vec4 fragColor;\n"
  "uniform sampler2D texture0;\n"
  "uniform vec4 colDiffuse;\n"
  "out vec4 finalColor;\n"
  "void main() {\n"
  "  vec4 c = texture(texture0, fragTexCoord) * colDiffuse * fragColor;\n"
  "  finalColor = vec4(1.0 - c.rgb, c.a);\n"
  "}\n";

Shader invertido = LoadShaderFromMemory(NULL, fs_invertido);
```

- Cada linha precisa terminar com `\n`: o `#version` deve estar sozinho na primeira linha, e as mensagens de erro do compilador indicam a linha certa

> Também é útil para gerar o código em tempo de execução, montando a string com `snprintf` (por exemplo, trocando o tamanho de um array de acordo com uma configuração)
