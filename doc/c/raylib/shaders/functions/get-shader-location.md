**GetShaderLocation**

> `raylib.h` — módulo `rcore`

O `GetShaderLocation` devolve a location de um uniform do shader, ou seja, o número que o programa usa para enviar valores para aquela variável

```c
int GetShaderLocation(Shader shader, const char *uniformName);
```

- `shader`: o shader
- `uniformName`: o nome do uniform, exatamente como declarado no GLSL

- Devolve a location, ou `-1` se o uniform não existe ou foi removido pelo compilador por não ser usado

```c
Shader s = LoadShader(NULL, "luz.fs");
int loc_pos_luz = GetShaderLocation(s, "posLuz");
int loc_cor_luz = GetShaderLocation(s, "corLuz");

if (loc_pos_luz == -1) {
  TraceLog(LOG_WARNING, "uniform posLuz não encontrado no shader");
}
```

> Procure as locations uma vez, depois de carregar o shader, e guarde em variáveis. O `-1` também aparece quando o uniform está declarado mas não é usado em nenhum cálculo: o compilador GLSL o remove (ver `../shader-locations.md`)
