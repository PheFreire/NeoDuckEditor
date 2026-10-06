**GetWorldToScreen**

> `raylib.h` — módulo `rcore`

O `GetWorldToScreen` converte uma posição 3D do mundo para a posição correspondente na tela, aplicando a câmera e a projeção. É usado para desenhar texto e interface 2D presos a objetos de uma cena 3D

```c
Vector2 GetWorldToScreen(Vector3 position, Camera camera);
```

- `position`: o ponto no mundo 3D
- `camera`: a câmera 3D usada para desenhar a cena

- Devolve a posição na tela, em pixels, considerando o tamanho atual da janela

```c
BeginMode3D(camera);
  DrawCube(inimigo.pos, 1, 2, 1, RED);
EndMode3D();

// barra de vida 2D acima do inimigo 3D
Vector3 topo = { inimigo.pos.x, inimigo.pos.y + 1.5f, inimigo.pos.z };
Vector2 tela = GetWorldToScreen(topo, camera);
DrawRectangle((int)tela.x - 25, (int)tela.y, 50 * inimigo.vida / 100, 6, GREEN);
```

---

**Pontos atrás da câmera**

- Um ponto atrás da câmera também é projetado, e pode aparecer espelhado em uma posição errada da tela
- Antes de desenhar, confira se o ponto está na frente, comparando com a direção da câmera:

```c
Vector3 para_ponto = Vector3Subtract(topo, camera.position);
Vector3 olhar = Vector3Subtract(camera.target, camera.position);
if (Vector3DotProduct(para_ponto, olhar) > 0) {
  // o ponto está na frente da câmera: pode desenhar
}
```

> Para projetar em uma área diferente da janela (como uma render texture de outro tamanho), use o `GetWorldToScreenEx`, que recebe a largura e a altura do destino (ver `get-world-to-screen-ex.md`)
