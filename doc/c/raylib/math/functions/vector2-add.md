**Vector2Add**

> `raymath.h`

O `Vector2Add` soma dois vetores, coordenada por coordenada. É a operação usada para mover um ponto por um deslocamento

```c
Vector2 Vector2Add(Vector2 v1, Vector2 v2);
```

- `v1`, `v2`: os vetores

- Devolve `(v1.x + v2.x, v1.y + v2.y)`
- Não altera os vetores originais

```c
Vector2 pos = { 100, 100 };
Vector2 vel = { 150, -50 };   // pixels por segundo

pos = Vector2Add(pos, Vector2Scale(vel, GetFrameTime()));   // posição += velocidade × tempo
```

```text
pos (100, 100) + deslocamento (3, -1) = (103, 99)
```

> Para somar o mesmo número às duas coordenadas, existe o `Vector2AddValue(v, valor)`
