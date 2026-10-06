**GetWorldToScreenEx**

> `raylib.h` — módulo `rcore`

O `GetWorldToScreenEx` converte uma posição 3D do mundo para coordenadas 2D em uma área de tamanho escolhido. É o mesmo que o `GetWorldToScreen`, mas sem assumir que o destino é a janela inteira

```c
Vector2 GetWorldToScreenEx(Vector3 position, Camera camera, int width, int height);
```

- `position`: o ponto no mundo 3D
- `camera`: a câmera 3D
- `width`, `height`: o tamanho da área de destino, em pixels

- Devolve a posição dentro de uma área de `width` x `height`

```c
// cena 3D desenhada em uma render texture de 320x180 (estilo pixel art), depois ampliada
RenderTexture2D alvo = LoadRenderTexture(320, 180);

Vector2 p = GetWorldToScreenEx(item.pos, camera, 320, 180);   // posição dentro da textura

BeginTextureMode(alvo);
  ClearBackground(BLACK);
  BeginMode3D(camera);
    DrawSphere(item.pos, 0.3f, GOLD);
  EndMode3D();
  DrawCircleLines((int)p.x, (int)p.y, 8, YELLOW);   // marcação 2D na mesma textura
EndTextureMode();
```

> A proporção (`width / height`) entra no cálculo da projeção. Usar o `GetWorldToScreen` com uma render texture de proporção diferente da janela gera posições deslocadas, e é exatamente esse caso que o `Ex` resolve
