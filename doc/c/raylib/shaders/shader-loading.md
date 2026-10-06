**Carregando shaders**

> `raylib.h` — módulo `rcore`

Um shader é carregado a partir do código-fonte GLSL, que o driver de vídeo compila na hora para a GPU. O código pode vir de arquivos (`.vs` e `.fs`) ou de strings dentro do programa

| Função | Carrega de |
|--------|------------|
| `LoadShader(vs_arquivo, fs_arquivo)` | arquivos |
| `LoadShaderFromMemory(vs_codigo, fs_codigo)` | strings com o código |
| `IsShaderValid(shader)` | confere se compilou |
| `UnloadShader(shader)` | libera |

- `NULL` em qualquer um dos dois estágios usa o shader padrão do raylib para aquele estágio
- Precisa da janela criada (o contexto OpenGL compila o shader)

```c
Shader s = LoadShader(NULL, "efeito.fs");   // só o fragment shader é próprio
if (!IsShaderValid(s)) {
  TraceLog(LOG_ERROR, "o shader não compilou, veja o log acima");
}
```

---

**O que acontece no carregamento**

```text
LoadShader
  │  lê o código dos arquivos
  ▼
  │  driver compila cada estágio (vertex, fragment)
  ▼
  │  liga os dois em um programa (link)
  ▼
  │  procura as variáveis com os nomes padrão e guarda as posições em shader.locs
  ▼
Shader { id, locs }
```

---

**Erros de compilação**

```text
WARNING: SHADER: [ID 4] Failed to compile fragment shader code
WARNING: SHADER: [ID 4] Compile error: ERROR: 0:12: 'finalColr' : undeclared identifier
```

- Os erros aparecem no log do raylib, com a linha do código GLSL. O programa **não** para: o shader fica inválido e os desenhos com ele não usam o efeito
- Erros comuns: esquecer o `#version`, misturar sintaxe GLSL 100 e 330, nome de variável errado, `float` sem ponto (`1` em vez de `1.0` em contas com `float`, em algumas versões)

---

**Recarregar sem fechar o programa**

```c
// tecla para recarregar o shader durante o desenvolvimento
if (IsKeyPressed(KEY_R)) {
  Shader novo = LoadShader(NULL, "efeito.fs");
  if (IsShaderValid(novo)) {
    UnloadShader(atual);
    atual = novo;            // só troca se o novo compilou
  }
}
```

> O código GLSL é compilado pelo driver da placa de vídeo, e drivers diferentes aceitam pequenas variações. Um shader que funciona em uma máquina pode falhar em outra: teste em mais de uma GPU e mantenha o código dentro do padrão da versão declarada no `#version`
