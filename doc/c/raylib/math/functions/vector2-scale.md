**Vector2Scale**

> `raymath.h`

O `Vector2Scale` multiplica as duas coordenadas de um vetor por um número, mudando o tamanho do vetor sem mudar a direção (ou invertendo, com um número negativo)

```c
Vector2 Vector2Scale(Vector2 v, float scale);
```

- `v`: o vetor
- `scale`: o fator

- Devolve `(v.x * scale, v.y * scale)`

```c
Vector2 direcao = Vector2Normalize(Vector2Subtract(alvo, pos));   // tamanho 1
Vector2 velocidade = Vector2Scale(direcao, 300);                 // tamanho 300
pos = Vector2Add(pos, Vector2Scale(velocidade, GetFrameTime())); // deslocamento deste frame
```

- `Vector2Scale(v, -1)` inverte a direção (o mesmo que `Vector2Negate`)
- Para multiplicar cada coordenada por um valor diferente, use `Vector2Multiply(v, (Vector2){ sx, sy })`

> O padrão "direção normalizada × velocidade × delta time" aparece em quase todo movimento de jogo: o `Vector2Scale` é a operação que dá tamanho à direção (ver `../vector2.md`)
