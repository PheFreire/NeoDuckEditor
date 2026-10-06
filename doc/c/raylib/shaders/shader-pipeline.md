**Pipeline de shaders**

> o caminho de um desenho dentro da GPU

Quando o raylib desenha algo, os vértices passam por uma sequência de etapas na GPU. Duas delas são programáveis com shaders: o vertex shader, que posiciona cada vértice, e o fragment shader, que colore cada pixel. As outras são fixas, feitas pelo hardware

```text
DrawTexture / DrawModel / DrawRectangle ...
  │  vértices: posição, coordenada de textura, cor, normal
  ▼
VERTEX SHADER (programável)          uma vez por vértice
  │  gl_Position = mvp * posição      → onde o vértice cai na tela
  │  repassa dados para o fragment shader (fragTexCoord, fragColor)
  ▼
rasterização (fixa)
  │  descobre quais pixels cada triângulo cobre
  │  interpola os dados dos 3 vértices para cada pixel
  ▼
FRAGMENT SHADER (programável)        uma vez por pixel coberto
  │  finalColor = cor calculada
  ▼
testes e mistura (fixos)
  │  depth test (3D), blending com o que já está na tela (alfa)
  ▼
framebuffer (tela ou render texture)
```

---

**Os dados que passam entre as etapas**

Vertex shader padrão do raylib (GLSL 330):

```glsl
#version 330
in vec3 vertexPosition;    // atributos: um valor por vértice
in vec2 vertexTexCoord;
in vec4 vertexColor;

uniform mat4 mvp;          // uniform: o mesmo para todos os vértices do desenho

out vec2 fragTexCoord;     // saída: vai para o fragment shader, interpolada
out vec4 fragColor;

void main() {
  fragTexCoord = vertexTexCoord;
  fragColor = vertexColor;
  gl_Position = mvp * vec4(vertexPosition, 1.0);
}
```

| Tipo | O que é | Exemplo |
|------|---------|---------|
| `in` no vertex | atributo de cada vértice, vindo da mesh | `vertexPosition`, `vertexTexCoord` |
| `uniform` | valor igual para o desenho inteiro, enviado pelo C | `mvp`, `texture0`, `colDiffuse`, `tempo` |
| `out` no vertex / `in` no fragment | valor por vértice, interpolado entre os vértices para cada pixel | `fragTexCoord`, `fragColor` |
| `out` no fragment | a cor final do pixel | `finalColor` |

---

**Interpolação**

```text
vértice A: fragColor = vermelho
vértice B: fragColor = azul           pixel no meio de A e B: roxo
```

- O que o vertex shader escreve nas saídas é misturado entre os vértices do triângulo, de acordo com a posição de cada pixel. É assim que uma coordenada de textura vai de `0` a `1` ao longo de um retângulo

> Os nomes `vertexPosition`, `vertexTexCoord`, `vertexColor`, `vertexNormal`, `mvp`, `texture0` e `colDiffuse` são os que o raylib procura automaticamente ao carregar um shader. Usando esses nomes, o shader próprio recebe os dados sem nenhuma configuração extra (ver `shader-locations.md`)
