**Colisão de linhas**

> `raylib.h` — módulo `rshapes`

As funções de colisão de linha verificam se dois segmentos de reta se cruzam e onde, ou se um ponto está sobre um segmento. São usadas para raios laser, linhas de visão, detecção de passagem por uma linha de chegada e para evitar que objetos rápidos atravessem paredes

```c
bool CheckCollisionLines(Vector2 startPos1, Vector2 endPos1,
                         Vector2 startPos2, Vector2 endPos2,
                         Vector2 *collisionPoint);
bool CheckCollisionPointLine(Vector2 point, Vector2 p1, Vector2 p2, int threshold);
```

- `CheckCollisionLines`: `true` se os dois segmentos se cruzam. O ponto de cruzamento é escrito em `*collisionPoint`
- `CheckCollisionPointLine`: `true` se o ponto está a até `threshold` pixels do segmento

---

**Segmento, e não reta infinita**

```text
   a1 ●──────────● a2
              ╳                    os segmentos se cruzam: colisão
   b1 ●──────────────● b2

   a1 ●────● a2
                  ╲               as retas se cruzariam fora dos segmentos: sem colisão
                   ● b1 ──● b2
```

- Os testes consideram só o trecho entre os dois pontos de cada segmento
- Segmentos paralelos nunca colidem pelo `CheckCollisionLines`

---

**Linha de visão**

```c
bool consegue_ver(Vector2 inimigo, Vector2 jogador, Rectangle *paredes, int n) {
  for (int i = 0; i < n; i++) {
    Rectangle w = paredes[i];
    Vector2 cantos[4] = {
      { w.x, w.y }, { w.x + w.width, w.y },
      { w.x + w.width, w.y + w.height }, { w.x, w.y + w.height },
    };
    for (int j = 0; j < 4; j++) {
      Vector2 p;
      if (CheckCollisionLines(inimigo, jogador, cantos[j], cantos[(j + 1) % 4], &p)) {
        return false;   // a linha entre os dois cruza um lado da parede
      }
    }
  }
  return true;
}
```

---

**Evitando o tunneling**

```c
Vector2 antes = bala.pos;
bala.pos = Vector2Add(bala.pos, Vector2Scale(bala.vel, dt));

Vector2 impacto;
if (CheckCollisionLines(antes, bala.pos, parede_a, parede_b, &impacto)) {
  bala.pos = impacto;   // a bala para exatamente onde cruzou a parede
  bala.ativa = false;
}
```

- Testar o caminho percorrido no frame, e não só a posição final, detecta a colisão mesmo com velocidades muito altas

> O ponteiro `collisionPoint` pode ser `NULL` se o ponto de cruzamento não for necessário. Quando os segmentos não se cruzam, o valor apontado não é alterado de forma útil, então só leia o ponto se a função devolver `true`
