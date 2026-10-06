**LoadShader**

> `raylib.h` — módulo `rcore`

O `LoadShader` lê o código GLSL de arquivos, compila na GPU e devolve o shader pronto para uso. Também procura as variáveis com os nomes padrão do raylib e guarda as locations delas

```c
Shader LoadShader(const char *vsFileName, const char *fsFileName);
```

- `vsFileName`: o arquivo do vertex shader, ou `NULL` para usar o padrão
- `fsFileName`: o arquivo do fragment shader, ou `NULL` para usar o padrão

- Devolve o `Shader` compilado
- Se a compilação falhar, os erros aparecem no log e o shader devolvido é inválido. Confira com `IsShaderValid`
- Precisa da janela criada

```c
Shader blur = LoadShader(NULL, "shaders/blur.fs");                    // só o fragment
Shader onda = LoadShader("shaders/onda.vs", "shaders/onda.fs");      // os dois

if (!IsShaderValid(blur)) {
  TraceLog(LOG_WARNING, "blur.fs não compilou, o jogo segue sem o efeito");
}
```

> A extensão dos arquivos (`.vs`, `.fs`, `.glsl`) não importa: o raylib lê o conteúdo como texto. O código precisa declarar a versão GLSL na primeira linha (`#version 330` no desktop), e usar os nomes padrão (`fragTexCoord`, `texture0`, `colDiffuse`) para receber os dados do raylib (ver `../shader-loading.md`)
