**shaders**

> `raylib.h` — módulos `rcore` e `rlgl`

Um shader é um pequeno programa que roda na **GPU**, escrito em GLSL (uma linguagem parecida com C), que decide a posição dos vértices e a cor de cada pixel desenhado. Todo desenho do raylib já passa por um shader padrão. Com shaders próprios, é possível criar efeitos que seriam caros ou impossíveis na CPU: iluminação, distorção, pós-processamento, água, contornos, transições

```c
Shader cinza = LoadShader(NULL, "cinza.fs");   // NULL: usa o vertex shader padrão

BeginDrawing();
ClearBackground(RAYWHITE);
BeginShaderMode(cinza);
  DrawTexture(foto, 0, 0, WHITE);   // desenhada pelo shader próprio
EndShaderMode();
EndDrawing();

UnloadShader(cinza);
```

```glsl
// cinza.fs: deixa tudo em tons de cinza
#version 330
in vec2 fragTexCoord;
in vec4 fragColor;
uniform sampler2D texture0;
uniform vec4 colDiffuse;
out vec4 finalColor;

void main() {
  vec4 c = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
  float cinza = dot(c.rgb, vec3(0.299, 0.587, 0.114));
  finalColor = vec4(vec3(cinza), c.a);
}
```

---

**Conteúdo**

| Assunto | Ver |
|---------|-----|
| o caminho dos vértices até os pixels | `shader-pipeline.md` |
| carregar shaders de arquivo ou de texto | `shader-loading.md` |
| locations: como o C encontra as variáveis do shader | `shader-locations.md` |
| uniforms: enviar valores do C para o shader | `uniforms.md` |
| ativar um shader para os desenhos | `shader-mode.md` |

- Cada função tem sua nota em `functions/`

---

**Vertex shader e fragment shader**

| | Vertex shader (`.vs`) | Fragment shader (`.fs`) |
|---|---|---|
| Roda | uma vez por **vértice** | uma vez por **pixel** coberto pelo desenho |
| Decide | onde o vértice aparece na tela | a cor final do pixel |
| Usos | deformar geometria (ondas, vento em árvores) | cores, iluminação, efeitos, pós-processamento |

- O raylib tem os dois padrão. Passar `NULL` em um deles mantém o padrão daquele estágio
- A maioria dos efeitos 2D só precisa de um fragment shader

---

**Versão do GLSL**

- No desktop, o raylib usa OpenGL 3.3, e os shaders começam com `#version 330`
- Em OpenGL ES 2.0 (web, celulares, Raspberry Pi), usa-se `#version 100`, com sintaxe um pouco diferente (`varying`, `gl_FragColor`, `texture2D`)
- Os exemplos oficiais do raylib trazem os mesmos shaders em pastas `glsl100` e `glsl330`

> O shader roda em paralelo para milhares de pixels ao mesmo tempo, e cada execução não enxerga as outras. Por isso, o fragment shader calcula a cor de um pixel olhando só para os dados daquele pixel (posição, coordenada de textura, uniforms), sem "laços sobre a imagem" (ver `../concepts/rendering-pipeline.md`)
