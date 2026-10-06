**Normalize**

> `raymath.h`

O `Normalize` converte um número para a escala de `0` a `1`, de acordo com a posição dele dentro de um intervalo. É o caminho inverso do `Lerp`: descobre a fração em vez de usá-la

```c
float Normalize(float value, float start, float end);
```

- `value`: o número
- `start`, `end`: o intervalo

- Devolve `(value - start) / (end - start)`
- `value == start` dá `0`, `value == end` dá `1`. Valores fora do intervalo dão resultados menores que `0` ou maiores que `1`

```c
float fracao_vida = Normalize(vida, 0, vida_max);            // 0 a 1
DrawRectangle(10, 10, (int)(200 * fracao_vida), 20, RED);

float progresso = Normalize(GetMusicTimePlayed(m), 0, GetMusicTimeLength(m));
```

> Não confunda com o `Vector2Normalize`, que tem outro significado: deixa um vetor com tamanho `1`, mantendo a direção (ver `vector2-normalize.md`). Para converter direto de um intervalo para outro, o `Remap` combina `Normalize` e `Lerp` em uma chamada
