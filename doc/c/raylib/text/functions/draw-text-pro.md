**DrawTextPro**

> `raylib.h` — módulo `rtext`

O `DrawTextPro` desenha um texto girado em torno de um ponto de origem, com uma fonte escolhida e espaçamento configurável

```c
void DrawTextPro(Font font, const char *text, Vector2 position, Vector2 origin,
                 float rotation, float fontSize, float spacing, Color tint);
```

- `font`: a fonte
- `text`: o texto, em UTF-8
- `position`: onde o ponto `origin` fica na tela
- `origin`: o ponto de rotação, relativo ao canto superior esquerdo do texto
- `rotation`: rotação em graus, no sentido horário
- `fontSize`: a altura das letras
- `spacing`: espaço extra entre as letras
- `tint`: a cor

- Não devolve nada

```c
// texto girando em torno do próprio centro
const char *msg = "GIRANDO";
Vector2 tam = MeasureTextEx(fonte, msg, 40, 2);
Vector2 origem = { tam.x / 2, tam.y / 2 };

DrawTextPro(fonte, msg, (Vector2){ 400, 225 }, origem, GetTime() * 90, 40, 2, RED);
```

- Para girar em torno do centro, a origem é metade do tamanho medido, e a `position` vira o centro na tela

> O esquema de `position` + `origin` + `rotation` é o mesmo do `DrawTexturePro` e do `DrawRectanglePro` (ver `../../texture/functions/draw-texture-pro.md`)
