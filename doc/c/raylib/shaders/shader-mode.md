**Shader mode**

> `raylib.h` — módulo `rcore`

O shader mode ativa um shader próprio para todos os desenhos 2D feitos entre `BeginShaderMode` e `EndShaderMode`. Para modelos 3D, o shader também pode ser colocado direto no material do modelo, sem precisar do shader mode

```c
void BeginShaderMode(Shader shader);
void EndShaderMode(void);
```

---

**Efeito em um objeto**

```c
BeginDrawing();
ClearBackground(RAYWHITE);

DrawTexture(fundo, 0, 0, WHITE);        // shader padrão

BeginShaderMode(contorno);
  DrawTexture(heroi, 100, 100, WHITE);  // só o herói recebe o contorno
EndShaderMode();

EndDrawing();
```

---

**Pós-processamento: efeito na tela inteira**

```text
1. desenhar a cena inteira em uma render texture (shader padrão)
2. desenhar a render texture na tela com o shader de efeito
```

```c
RenderTexture2D cena = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());
Shader crt = LoadShader(NULL, "crt.fs");

while (!WindowShouldClose()) {
  BeginTextureMode(cena);
    ClearBackground(BLACK);
    desenhar_jogo();
  EndTextureMode();

  BeginDrawing();
    BeginShaderMode(crt);   // o efeito é aplicado a cada pixel da cena
      DrawTextureRec(cena.texture,
                     (Rectangle){ 0, 0, cena.texture.width, -cena.texture.height },
                     (Vector2){ 0, 0 }, WHITE);
    EndShaderMode();
    DrawFPS(10, 10);        // interface sem o efeito
  EndDrawing();
}
```

- O fragment shader recebe a cena como `texture0` e pode distorcer, mudar cores, borrar ou aplicar qualquer efeito sobre ela

---

**Shader em modelos 3D**

```c
Model estatua = LoadModel("estatua.glb");
estatua.materials[0].shader = iluminacao;   // o modelo sempre desenha com esse shader

BeginMode3D(camera);
  DrawModel(estatua, (Vector3){ 0 }, 1.0f, WHITE);
EndMode3D();
```

- Atribuir o shader ao material vale para todos os desenhos do modelo, sem `BeginShaderMode`

> Trocar de shader obriga o raylib a enviar à GPU o que estava acumulado (o batch). Agrupe os desenhos por shader: muitos `BeginShaderMode`/`EndShaderMode` intercalados em um frame reduzem o desempenho
