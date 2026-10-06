**Vector3Length**

> `raymath.h`

O `Vector3Length` calcula o tamanho de um vetor 3D

```c
float Vector3Length(const Vector3 v);
```

- `v`: o vetor

- Devolve `√(v.x² + v.y² + v.z²)`

```c
float velocidade = Vector3Length(carro.vel);
DrawText(TextFormat("%.0f km/h", velocidade * 3.6f), 10, 10, 20, BLACK);   // m/s para km/h

// ativar uma armadilha quando o jogador chega perto
if (Vector3Length(Vector3Subtract(jogador.pos, armadilha.pos)) < 2.0f) {
  disparar(armadilha);
}
```

> Para comparar distâncias, `Vector3LengthSqr` ou `Vector3DistanceSqr` evitam a raiz quadrada: compare com o quadrado do limite (`< 2.0f * 2.0f`)
