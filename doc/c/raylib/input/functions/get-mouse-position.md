**GetMousePosition**

> `raylib.h` — módulo `rcore`

O `GetMousePosition` devolve a posição do cursor do mouse dentro da janela, em pixels, como um `Vector2`. É a forma mais usada de ler o mouse, pois o `Vector2` pode ser passado direto para as funções de colisão, desenho e matemática

```c
Vector2 GetMousePosition(void);
```

- Devolve um `Vector2` com `x` e `y` do cursor, em coordenadas da janela (tela)
- Com `DisableCursor`, devolve uma posição virtual sem limites, que não corresponde a nenhum ponto da tela

```c
Vector2 mouse = GetMousePosition();

// fazer um objeto olhar para o mouse
float angulo = atan2f(mouse.y - nave.y, mouse.x - nave.x) * RAD2DEG;

// testar se o mouse está sobre um círculo
bool sobre = CheckCollisionPointCircle(mouse, centro, raio);
```

---

**Com câmera 2D**

```c
Vector2 mouse_tela  = GetMousePosition();
Vector2 mouse_mundo = GetScreenToWorld2D(mouse_tela, camera);

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
  colocar_bloco(mouse_mundo);   // posição no mapa, considerando o movimento e o zoom da câmera
}
```

- A posição devolvida é sempre da **tela**. Com uma câmera que se move ou dá zoom, ela precisa ser convertida para o mundo (ver `../../camera/coordinate-conversion.md`)

> A posição é em pixels lógicos da janela. Em telas HighDPI, isso continua correto para desenhar, pois o raylib desenha nas mesmas coordenadas lógicas
