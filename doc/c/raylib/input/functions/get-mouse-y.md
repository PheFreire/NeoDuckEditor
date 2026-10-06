**GetMouseY**

> `raylib.h` — módulo `rcore`

O `GetMouseY` devolve a posição vertical do cursor do mouse dentro da janela, em pixels, como inteiro

```c
int GetMouseY(void);
```

- Devolve a coordenada `y` do cursor: `0` no topo da janela, crescendo para **baixo**
- Pode ser negativa ou maior que a altura da janela se o cursor estiver fora dela

```c
// destaca a linha de uma lista sob o cursor
int altura_linha = 30;
int linha = (GetMouseY() - lista_y) / altura_linha;
if (linha >= 0 && linha < total_linhas) {
  DrawRectangle(lista_x, lista_y + linha * altura_linha, 300, altura_linha, Fade(SKYBLUE, 0.4f));
}
```

> O eixo `y` da tela cresce para baixo, o contrário do plano cartesiano da matemática. Em fórmulas que assumem `y` para cima (ângulos, física), inverta o sinal (ver `../../drawing/coordinates.md`)
