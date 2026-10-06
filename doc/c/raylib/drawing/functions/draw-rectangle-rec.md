**DrawRectangleRec**

> `raylib.h` — módulo `rshapes`

O `DrawRectangleRec` desenha um retângulo preenchido a partir de uma struct `Rectangle`. É a forma mais usada quando o retângulo também participa da lógica do jogo, como colisões e cliques

```c
void DrawRectangleRec(Rectangle rec, Color color);
```

- `rec`: o retângulo, com `x`, `y` (canto superior esquerdo), `width` e `height`
- `color`: a cor de preenchimento

- Não devolve nada

```c
Rectangle botao = { 300, 200, 200, 60 };
bool sobre = CheckCollisionPointRec(GetMousePosition(), botao);

DrawRectangleRec(botao, sobre ? SKYBLUE : LIGHTGRAY);
DrawRectangleLinesEx(botao, 2, DARKBLUE);
DrawText("JOGAR", botao.x + 60, botao.y + 18, 24, DARKBLUE);
```

> Usar a mesma variável `Rectangle` para desenhar e para testar colisão garante que o que o jogador vê é exatamente a área que reage ao jogo, sem diferenças entre a imagem e a hitbox
