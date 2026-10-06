**EndTextureMode**

> `raylib.h` — módulo `rcore`

O `EndTextureMode` termina o desenho dentro de uma render texture e volta a desenhar na tela

```c
void EndTextureMode(void);
```

- Não recebe parâmetros e não devolve nada
- Envia à GPU o que foi desenhado na textura, volta ao framebuffer da janela e restaura a área de desenho com o tamanho da tela

```c
BeginTextureMode(espelho);
  ClearBackground(SKYBLUE);
  BeginMode3D(camera_espelho);
    desenhar_cena();
  EndMode3D();
EndTextureMode();   // a partir daqui, o desenho volta para a tela

BeginDrawing();
  BeginMode3D(camera);
    desenhar_cena();
  EndMode3D();
  DrawTextureRec(espelho.texture, (Rectangle){ 0, 0, 256, -144 }, (Vector2){ 10, 10 }, WHITE);
EndDrawing();
```

> Depois do `EndTextureMode`, o conteúdo da textura fica guardado na GPU até ser limpo ou sobrescrito. Uma render texture que não é limpa todo frame acumula o desenho, o que é útil para programas de pintura e rastros
