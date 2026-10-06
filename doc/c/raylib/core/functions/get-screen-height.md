**GetScreenHeight**

> `raylib.h` — módulo `rcore`

O `GetScreenHeight` devolve a altura atual da área de desenho da janela, em pixels. É o par do `GetScreenWidth`, usado para posicionar elementos em relação ao topo, à base e ao centro vertical da tela

```c
int GetScreenHeight(void);
```

- Devolve a altura atual da janela, em pixels lógicos, sem a barra de título
- Muda quando a janela é redimensionada

```c
int largura = GetScreenWidth();
int altura  = GetScreenHeight();

// centro da tela
Vector2 centro = { largura / 2.0f, altura / 2.0f };
DrawCircleV(centro, 20, RED);

// barra de vida na parte de baixo
DrawRectangle(10, altura - 30, 200, 20, GREEN);
```

---

**O eixo y cresce para baixo**

```text
(0, 0) ───────────────────────► x
  │
  │
  │        (largura/2, altura/2)
  │
  ▼
  y                    (largura, altura)
```

- No sistema de coordenadas da tela do raylib, `y = 0` é o topo e `y = GetScreenHeight()` é a base (ver `../../drawing/coordinates.md`)

> Ao configurar uma `Camera2D` para seguir o jogador, o `offset` normalmente é o centro da tela: `(Vector2){ GetScreenWidth() / 2.0f, GetScreenHeight() / 2.0f }`. Atualize esse valor quando a janela mudar de tamanho (ver `../../camera/camera-2d.md`)
