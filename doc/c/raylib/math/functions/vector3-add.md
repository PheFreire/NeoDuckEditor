**Vector3Add**

> `raymath.h`

O `Vector3Add` soma dois vetores 3D, coordenada por coordenada. É a operação usada para mover um ponto no espaço

```c
Vector3 Vector3Add(Vector3 v1, Vector3 v2);
```

- `v1`, `v2`: os vetores

- Devolve `(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)`

```c
// física simples com gravidade
Vector3 gravidade = { 0, -9.8f, 0 };
float dt = GetFrameTime();

bola.vel = Vector3Add(bola.vel, Vector3Scale(gravidade, dt));   // velocidade += aceleração × tempo
bola.pos = Vector3Add(bola.pos, Vector3Scale(bola.vel, dt));    // posição += velocidade × tempo
```

> O mesmo que o `Vector2Add` com uma coordenada a mais (ver `vector2-add.md`)
