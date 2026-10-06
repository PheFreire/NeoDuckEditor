**DrawRectanglePro**

> `raylib.h` — módulo `rshapes`

O `DrawRectanglePro` desenha um retângulo preenchido e rotacionado em torno de um ponto de origem

```c
void DrawRectanglePro(Rectangle rec, Vector2 origin, float rotation, Color color);
```

- `rec`: o retângulo. `rec.x` e `rec.y` indicam onde a **origem** fica na tela, e não o canto
- `origin`: o ponto de rotação, relativo ao canto superior esquerdo do retângulo
- `rotation`: o ângulo em graus, no sentido horário (por causa do `y` para baixo)
- `color`: a cor de preenchimento

- Não devolve nada

```c
// retângulo girando em torno do próprio centro
Rectangle r = { 400, 225, 120, 60 };          // o centro ficará em (400, 225)
Vector2 origem = { r.width / 2, r.height / 2 }; // origem no centro do retângulo
DrawRectanglePro(r, origem, GetTime() * 90, ORANGE);
```

---

**Como a origem funciona**

```text
origin = (0, 0)                     origin = (w/2, h/2)
gira em torno do canto              gira em torno do centro

(x, y)●───────┐                     ┌───────┐
      │       │                     │   ●   │ ← (x, y)
      └───────┘                     └───────┘
```

- A origem é o ponto do retângulo que fica fixo em `(rec.x, rec.y)` e em torno do qual ele gira
- Com origem `(0, 0)`, o retângulo gira em torno do canto, como uma porta na dobradiça

> O mesmo esquema de origem e rotação é usado pelo `DrawTexturePro` e pelo `DrawTextPro`, então entender esta função ajuda a usar as outras duas (ver `../../texture/functions/draw-texture-pro.md`)
