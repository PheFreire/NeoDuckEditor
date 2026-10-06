**CheckCollisionBoxes**

> `raylib.h` — módulo `rmodels`

O `CheckCollisionBoxes` verifica se duas caixas 3D alinhadas aos eixos (bounding boxes) se sobrepõem. É a versão 3D do `CheckCollisionRecs`

```c
bool CheckCollisionBoxes(BoundingBox box1, BoundingBox box2);
```

- `box1`, `box2`: as caixas, cada uma com os cantos `min` e `max`

- Devolve `true` se as caixas se sobrepõem nos três eixos (`x`, `y` e `z`)

```c
BoundingBox caixa_de(Vector3 pos, Vector3 tamanho) {
  return (BoundingBox){
    .min = { pos.x - tamanho.x / 2, pos.y - tamanho.y / 2, pos.z - tamanho.z / 2 },
    .max = { pos.x + tamanho.x / 2, pos.y + tamanho.y / 2, pos.z + tamanho.z / 2 },
  };
}

BoundingBox jogador = caixa_de(pos_jogador, (Vector3){ 1, 2, 1 });
BoundingBox parede  = caixa_de(pos_parede,  (Vector3){ 4, 3, 0.5f });

if (CheckCollisionBoxes(jogador, parede)) {
  pos_jogador = pos_anterior;   // desfaz o movimento
}
```

---

**Caixa de um modelo**

```c
BoundingBox local = GetModelBoundingBox(modelo);   // no espaço do próprio modelo
BoundingBox mundo = {
  Vector3Add(local.min, posicao),
  Vector3Add(local.max, posicao),
};
```

- O `GetModelBoundingBox` calcula a caixa em relação à origem do modelo. Para colidir na cena, desloque a caixa pela posição do objeto. Com escala ou rotação, a caixa também precisa ser transformada (ver `../../models/bounding-box.md`)

> Como no 2D, as caixas não giram: um objeto rotacionado precisa de uma caixa maior que o envolva em qualquer ângulo, ou de uma esfera como forma de colisão
