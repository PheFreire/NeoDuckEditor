**CheckCollisionRecs**

> `raylib.h` — módulo `rshapes`

O `CheckCollisionRecs` verifica se dois retângulos alinhados aos eixos se sobrepõem. É o teste de colisão mais usado em jogos 2D: personagens, plataformas, paredes, inimigos e tiros

```c
bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2);
```

- `rec1`, `rec2`: os retângulos, com `x`, `y` (canto superior esquerdo), `width` e `height`

- Devolve `true` se os retângulos se sobrepõem, e `false` caso contrário
- Retângulos que só encostam na borda (sem área em comum) **não** colidem
- Não considera rotação

```c
Rectangle jogador = { 100, 300, 32, 48 };
Rectangle inimigo = { 120, 320, 32, 32 };

if (CheckCollisionRecs(jogador, inimigo)) {
  vida -= 1;
}
```

---

**Como funciona**

```c
// equivalente ao que o raylib faz
bool colidem = rec1.x < rec2.x + rec2.width  && rec1.x + rec1.width  > rec2.x &&
               rec1.y < rec2.y + rec2.height && rec1.y + rec1.height > rec2.y;
```

- Sobreposição em `x` e em `y` ao mesmo tempo. Se faltar em um dos eixos, não há colisão

> Para saber o quanto os retângulos se sobrepõem, e não só se colidem, use o `GetCollisionRec` (ver `get-collision-rec.md`). A resolução da colisão (empurrar para fora) é explicada em `../collision-2d.md`
