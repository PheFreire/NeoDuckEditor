**CheckCollisionLines**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionLines` verifica se dois segmentos de reta se cruzam e, se sim, informa o ponto de cruzamento

```c
bool CheckCollisionLines(Vector2 startPos1, Vector2 endPos1,
                         Vector2 startPos2, Vector2 endPos2,
                         Vector2 *collisionPoint);
```

- `startPos1`, `endPos1`: o primeiro segmento
- `startPos2`, `endPos2`: o segundo segmento
- `collisionPoint`: ponteiro onde o ponto de cruzamento será escrito. Pode ser `NULL` se não for necessário

- Devolve `true` se os segmentos se cruzam, e `false` caso contrário
- Só considera o trecho entre os pontos de cada segmento, e não as retas infinitas
- Segmentos paralelos (inclusive sobrepostos) devolvem `false`

```c
// laser: encontra onde o raio bate na parede
Vector2 inicio = arma;
Vector2 fim = { arma.x + cosf(ang) * 1000, arma.y + sinf(ang) * 1000 };
Vector2 impacto;

if (CheckCollisionLines(inicio, fim, parede_a, parede_b, &impacto)) {
  fim = impacto;   // o laser para na parede
}
DrawLineEx(inicio, fim, 3, RED);
```

---

**Passagem por uma linha**

```c
// linha de chegada: detecta se o carro cruzou nesta volta
Vector2 antes = carro.pos_anterior;
if (CheckCollisionLines(antes, carro.pos, chegada_a, chegada_b, NULL)) {
  voltas++;
}
```

- Testar o caminho entre a posição anterior e a atual detecta a passagem mesmo se o carro for rápido o suficiente para nunca estar exatamente sobre a linha

> A técnica de testar o movimento do frame como um segmento é a forma mais simples de evitar o tunneling, quando um objeto rápido atravessa uma parede fina (ver `../line-collision.md`)
