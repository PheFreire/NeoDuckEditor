**Colisão de ponto**

> `raylib.h` — módulo `rshapes`

As funções de colisão de ponto verificam se um ponto está dentro de uma forma. O uso mais comum é com o mouse: saber se o cursor está sobre um botão, um personagem ou uma célula do mapa

| Função | Verdadeiro se o ponto está dentro de |
|--------|--------------------------------------|
| `CheckCollisionPointRec(p, rec)` | um retângulo |
| `CheckCollisionPointCircle(p, centro, raio)` | um círculo |
| `CheckCollisionPointTriangle(p, a, b, c)` | um triângulo |
| `CheckCollisionPointPoly(p, pontos, n)` | um polígono qualquer |
| `CheckCollisionPointLine(p, a, b, tolerância)` | perto de um segmento (até `tolerância` pixels) |

```c
Vector2 mouse = GetMousePosition();

if (CheckCollisionPointRec(mouse, botao_jogar))   cor_botao = SKYBLUE;
if (CheckCollisionPointCircle(mouse, moeda, 12))  DrawText("moeda", mouse.x, mouse.y - 20, 16, GOLD);
```

---

**Como cada teste funciona**

```text
retângulo:   rec.x <= p.x < rec.x + rec.width   e   rec.y <= p.y < rec.y + rec.height

círculo:     distância(p, centro)² <= raio²      (sem raiz quadrada)

triângulo:   o ponto está do mesmo lado das três arestas
```

- O teste do círculo compara os quadrados das distâncias para evitar o `sqrt`, que é mais caro
- No retângulo, as bordas esquerda e superior contam como dentro, e as bordas direita e inferior não. Assim, retângulos vizinhos (como células de uma grade) nunca contêm o mesmo ponto

---

**Mouse com câmera**

```c
Vector2 mouse_mundo = GetScreenToWorld2D(GetMousePosition(), camera);

for (int i = 0; i < n_unidades; i++) {
  if (CheckCollisionPointCircle(mouse_mundo, unidades[i].pos, unidades[i].raio)) {
    selecionada = i;
  }
}
```

> O ponto e a forma precisam estar no mesmo sistema de coordenadas. Testar a posição do mouse na tela contra objetos posicionados no mundo dá resultados errados assim que a câmera se move (ver `../camera/coordinate-conversion.md`)
