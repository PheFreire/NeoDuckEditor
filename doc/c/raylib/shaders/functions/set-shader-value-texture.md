**SetShaderValueTexture**

> `raylib.h` — módulo `rcore`

O `SetShaderValueTexture` liga uma textura a um uniform `sampler2D` do shader, permitindo que o shader leia mais de uma textura no mesmo desenho

```c
void SetShaderValueTexture(Shader shader, int locIndex, Texture2D texture);
```

- `shader`: o shader
- `locIndex`: a location do uniform `sampler2D`
- `texture`: a textura

- Não devolve nada
- A textura principal do desenho já chega como `texture0`. Esta função é para texturas extras (`texture1`, máscaras, ruído, paletas)

```glsl
uniform sampler2D texture0;   // a textura desenhada (automática)
uniform sampler2D ruido;      // extra

void main() {
  float r = texture(ruido, fragTexCoord).r;
  vec4 c = texture(texture0, fragTexCoord);
  if (r < limite) discard;    // efeito de dissolver
  finalColor = c;
}
```

```c
Texture2D ruido = LoadTexture("ruido.png");
int loc_ruido = GetShaderLocation(dissolver, "ruido");

BeginShaderMode(dissolver);
  SetShaderValueTexture(dissolver, loc_ruido, ruido);   // dentro do shader mode
  DrawTexture(inimigo, x, y, WHITE);
EndShaderMode();
```

> Chame dentro do `BeginShaderMode`, antes do desenho. A textura extra é ligada a uma unidade de textura que só vale para o desenho em andamento, e precisa ser ligada de novo a cada uso
