**GetCollisionRec**

> `raylib.h` — módulo `rshapes`

O `GetCollisionRec` devolve o retângulo da área de sobreposição entre dois retângulos. Diz não só **se** eles colidiram, mas **quanto** e **onde**

```c
Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2);
```

- `rec1`, `rec2`: os retângulos

- Devolve a interseção dos dois retângulos
- Sem sobreposição, devolve um retângulo com `width` e `height` iguais a `0`

```text
┌─────────┐
│ rec1 ┌──┼──────┐
│      │▓▓│      │      ▓▓ = GetCollisionRec(rec1, rec2)
└──────┼──┘ rec2 │
       └─────────┘
```

```c
if (CheckCollisionRecs(jogador, parede)) {
  Rectangle sob = GetCollisionRec(jogador, parede);

  // empurra pelo eixo de menor sobreposição
  if (sob.width < sob.height) {
    jogador.x += (jogador.x < parede.x) ? -sob.width : sob.width;
  } else {
    jogador.y += (jogador.y < parede.y) ? -sob.height : sob.height;
  }
}
```

---

**Outros usos**

- Calcular a área visível de uma janela de interface dentro de outra (interseção de áreas de scissor)
- Medir o quanto um objeto está dentro de uma área (por exemplo, a porcentagem do jogador dentro da água: `sob.width * sob.height / (jogador.width * jogador.height)`)

> Empurrar pelo eixo de menor sobreposição funciona bem na maioria dos casos, mas pode errar em cantos, quando as duas sobreposições são parecidas. A resolução por eixo separado, movendo e testando primeiro `x` e depois `y`, é mais robusta (ver `../collision-2d.md`)
