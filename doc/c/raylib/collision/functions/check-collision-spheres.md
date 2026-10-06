**CheckCollisionSpheres**

> `raylib.h` — módulo `rmodels`

O `CheckCollisionSpheres` verifica se duas esferas se sobrepõem no espaço 3D. É a versão 3D do `CheckCollisionCircles`

```c
bool CheckCollisionSpheres(Vector3 center1, float radius1, Vector3 center2, float radius2);
```

- `center1`, `radius1`: a primeira esfera
- `center2`, `radius2`: a segunda esfera

- Devolve `true` se a distância entre os centros for menor ou igual à soma dos raios

```c
// coletar itens em 3D
for (int i = 0; i < n_itens; i++) {
  if (itens[i].ativo && CheckCollisionSpheres(jogador.pos, 0.5f, itens[i].pos, 0.3f)) {
    itens[i].ativo = false;
    pontos++;
  }
}

DrawSphere(jogador.pos, 0.5f, BLUE);   // a esfera de colisão pode ser desenhada para depurar
```

> Esferas são as formas de colisão 3D mais baratas e são iguais em qualquer rotação. Personagens costumam usar uma cápsula ou várias esferas empilhadas, e itens e projéteis uma única esfera
