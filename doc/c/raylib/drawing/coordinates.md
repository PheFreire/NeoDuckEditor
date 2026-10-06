**Coordenadas 2D**

> sistema de coordenadas da tela no raylib

As funções de desenho 2D usam coordenadas em pixels, com a origem `(0, 0)` no **canto superior esquerdo** da janela. O eixo `x` cresce para a direita e o eixo `y` cresce para **baixo**, ao contrário do plano cartesiano usado na matemática

```text
(0, 0) ─────────────────────────────► x
  │
  │      (100, 50)
  │         ●
  │
  │                  (400, 225) centro de uma janela 800x450
  │                      ●
  │
  ▼                                   (800, 450)
  y
```

- `x = 0` é a borda esquerda e `x = GetScreenWidth()` a direita
- `y = 0` é o topo e `y = GetScreenHeight()` a base
- Coordenadas fora desse intervalo são válidas: o que está fora simplesmente não aparece

---

**Onde fica a "posição" de cada forma**

| Forma | A posição é |
|-------|-------------|
| `DrawRectangle(x, y, w, h)` | o canto **superior esquerdo** |
| `DrawCircle(x, y, r)` | o **centro** |
| `DrawText(texto, x, y, ...)` | o canto superior esquerdo do texto |
| `DrawTexture(t, x, y, ...)` | o canto superior esquerdo da imagem |
| `DrawPoly(centro, ...)` | o **centro** |

- Misturar as duas convenções é um erro comum: um círculo e um retângulo com a mesma posição não ficam alinhados

```c
// centralizar um retângulo em um ponto
Vector2 centro = { 400, 225 };
DrawRectangle(centro.x - 50, centro.y - 25, 100, 50, BLUE);   // canto = centro - metade do tamanho
DrawCircleV(centro, 25, RED);                                  // círculo já usa o centro
```

---

**Y para baixo e ângulos**

- Como o `y` cresce para baixo, um ângulo positivo gira no sentido **horário** na tela, o contrário da matemática
- Para mover "para cima", subtraia de `y`: `pos.y -= velocidade * dt`
- A gravidade em jogos 2D é um valor **positivo** em `y`

---

**Inteiros e floats**

- Funções simples (`DrawRectangle`, `DrawCircle`) recebem `int`. Versões `V`, `Rec` e `Ex` recebem `float`, em `Vector2` e `Rectangle`
- Guarde as posições do jogo em `float` (para movimento suave com delta time) e use as versões `V` para desenhar, evitando que o objeto "trave" de pixel em pixel

> Com uma câmera 2D, existem dois sistemas: o da **tela** (descrito aqui, fixo) e o do **mundo** (onde ficam os objetos do jogo, movido e escalado pela câmera). Ver `../camera/world-space.md` e `../camera/screen-space.md`
