**IsKeyDown**

> `raylib.h` — módulo `rcore`

O `IsKeyDown` verifica se uma tecla está apertada agora. Devolve `true` em todos os frames enquanto a tecla está segurada, e é usado para ações contínuas: andar, acelerar, girar

```c
bool IsKeyDown(int key);
```

- `key`: a tecla, como uma constante `KEY_*`

- Devolve `true` enquanto a tecla está apertada, e `false` enquanto está solta

```c
float dt = GetFrameTime();
Vector2 dir = { 0 };

if (IsKeyDown(KEY_W) || IsKeyDown(KEY_UP))    dir.y -= 1;
if (IsKeyDown(KEY_S) || IsKeyDown(KEY_DOWN))  dir.y += 1;
if (IsKeyDown(KEY_A) || IsKeyDown(KEY_LEFT))  dir.x -= 1;
if (IsKeyDown(KEY_D) || IsKeyDown(KEY_RIGHT)) dir.x += 1;

dir = Vector2Normalize(dir);   // diagonal com a mesma velocidade das retas
pos.x += dir.x * 200 * dt;
pos.y += dir.y * 200 * dt;
```

- Sem o `Vector2Normalize`, andar na diagonal seria cerca de 41% mais rápido (`√2`), pois `x` e `y` somam ao mesmo tempo (ver `../../math/functions/vector2-normalize.md`)
- Como é verdadeiro todo frame, o movimento precisa ser multiplicado pelo delta time para não depender do FPS (ver `../../concepts/delta-time.md`)

> Para ações que devem acontecer uma vez por aperto, use o `IsKeyPressed`. Com o `IsKeyDown`, um tiro ou um pulo seria disparado em todos os frames enquanto a tecla estiver segurada
