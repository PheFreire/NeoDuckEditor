**Círculos e elipses**

> `raylib.h` — módulo `rshapes`

As funções de círculo desenham círculos preenchidos, contornos, gradientes, setores (fatias de pizza), anéis e elipses. Todas posicionam a forma pelo **centro**, e não pelo canto como o retângulo

| Função | Desenha |
|--------|---------|
| `DrawCircle(cx, cy, raio, cor)` | círculo preenchido, com centro `int` |
| `DrawCircleV(centro, raio, cor)` | círculo preenchido, com centro `Vector2` |
| `DrawCircleLines(cx, cy, raio, cor)` | contorno |
| `DrawCircleGradient(cx, cy, raio, dentro, fora)` | gradiente do centro para a borda |
| `DrawCircleSector(centro, raio, ini, fim, segmentos, cor)` | fatia entre dois ângulos |
| `DrawRing(centro, raio_int, raio_ext, ini, fim, segmentos, cor)` | anel (rosca) |
| `DrawEllipse(cx, cy, raioH, raioV, cor)` | elipse com raios horizontal e vertical |
| `DrawEllipseLines(cx, cy, raioH, raioV, cor)` | contorno da elipse |

```c
DrawCircleV(jogador, 16, BLUE);
DrawCircleLines(400, 225, 100, GRAY);                       // área de alcance
DrawCircleGradient(400, 225, 80, Fade(YELLOW, 0.8f), BLANK);  // luz suave
DrawEllipse(400, 400, 60, 15, Fade(BLACK, 0.3f));           // sombra achatada no chão
```

---

**Círculos são polígonos**

```text
círculo de raio pequeno         círculo de raio grande
poucos segmentos                mais segmentos
   ⬡                               ◯
```

- A GPU só desenha triângulos, então um círculo é um polígono com muitos lados. O raylib escolhe a quantidade de segmentos automaticamente pelo tamanho do raio, para que a borda pareça redonda
- Funções como `DrawCircleSector` e `DrawRing` recebem `segments` explicitamente: valores maiores deixam a curva mais suave e custam mais triângulos

---

**Barra de progresso circular**

```c
float progresso = tempo / duracao;   // 0 a 1
DrawRing((Vector2){ 400, 225 }, 40, 50, -90, -90 + 360 * progresso, 64, SKYBLUE);
```

- Os ângulos são em graus. `0` aponta para a direita, e como o `y` cresce para baixo, ângulos maiores giram no sentido horário. Começar em `-90` faz o anel começar no topo

> Para colisão, um círculo é só um centro e um raio, o que torna o teste muito barato: dois círculos colidem quando a distância entre os centros é menor que a soma dos raios (ver `../collision/circle-collision.md`)
