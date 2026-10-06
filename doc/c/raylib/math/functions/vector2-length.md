**Vector2Length**

> `raymath.h`

O `Vector2Length` calcula o tamanho (módulo) de um vetor, pelo teorema de Pitágoras

```c
float Vector2Length(Vector2 v);
```

- `v`: o vetor

- Devolve `√(v.x² + v.y²)`

```c
float velocidade = Vector2Length(jogador.vel);   // velocidade escalar, em pixels por segundo
if (velocidade > 400) {
  jogador.vel = Vector2Scale(Vector2Normalize(jogador.vel), 400);   // limita a velocidade máxima
}

float distancia = Vector2Length(Vector2Subtract(a, b));   // o mesmo que Vector2Distance(a, b)
```

> Para comparar tamanhos, o `Vector2LengthSqr` devolve o valor sem a raiz quadrada, que é mais barato: `Vector2LengthSqr(v) > 400 * 400` dá o mesmo resultado que `Vector2Length(v) > 400`
