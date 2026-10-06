**Clamp**

> `raymath.h`

O `Clamp` limita um número a um intervalo: se for menor que o mínimo, devolve o mínimo, se for maior que o máximo, devolve o máximo, e caso contrário devolve o próprio número

```c
float Clamp(float value, float min, float max);
```

- `value`: o número
- `min`, `max`: os limites do intervalo

- Devolve `value` limitado entre `min` e `max`

```c
vida = Clamp(vida - dano, 0, vida_max);   // nunca fica negativa nem passa do máximo
camera.zoom = Clamp(camera.zoom + GetMouseWheelMove() * 0.1f, 0.25f, 4.0f);
jogador.x = Clamp(jogador.x, 0, GetScreenWidth() - jogador.width);   // não sai da tela
```

> Para vetores, existem `Vector2Clamp(v, min, max)` (limita cada coordenada) e `Vector2ClampValue(v, min, max)` (limita o tamanho do vetor, mantendo a direção). O `fminf`/`fmaxf` da `math.h` faz o mesmo combinando os dois (ver `../../../math/arithmetic/fmin_fmax.md`)
