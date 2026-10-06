**IsShaderValid**

> `raylib.h` — módulo `rcore`

O `IsShaderValid` verifica se um shader foi compilado e carregado com sucesso na GPU

```c
bool IsShaderValid(Shader shader);
```

- `shader`: o shader

- Devolve `true` se o shader está carregado e tem as locations alocadas, e `false` caso contrário

```c
Shader efeito = LoadShader(NULL, "efeito.fs");
bool usar_efeito = IsShaderValid(efeito);

BeginDrawing();
if (usar_efeito) BeginShaderMode(efeito);
  desenhar_jogo();
if (usar_efeito) EndShaderMode();
EndDrawing();
```

> Até o raylib 5.0, essa função se chamava `IsShaderReady`. Ela indica só que o shader compilou, e não que ele produz o efeito esperado: uniforms com location `-1` ou nomes errados de variáveis ainda deixam o shader "válido" (ver `../shader-locations.md`)
