**DrawModelEx**

> `raylib.h` — módulo `rmodels`

O `DrawModelEx` desenha um modelo com posição, rotação em torno de um eixo e escala diferente em cada eixo

```c
void DrawModelEx(Model model, Vector3 position, Vector3 rotationAxis,
                 float rotationAngle, Vector3 scale, Color tint);
```

- `model`: o modelo
- `position`: onde a origem do modelo fica no mundo
- `rotationAxis`: o eixo em torno do qual girar, como `(0, 1, 0)` para o eixo `y`
- `rotationAngle`: o ângulo, em graus
- `scale`: escala em `x`, `y` e `z`
- `tint`: cor que multiplica as cores do material

- Não devolve nada
- Aplica escala, depois rotação, depois translação, sobre a `model.transform`

```c
// moeda girando no próprio eixo vertical
DrawModelEx(moeda, pos_moeda, (Vector3){ 0, 1, 0 }, GetTime() * 180, (Vector3){ 1, 1, 1 }, GOLD);

// personagem virado para a direção em que anda
float angulo = atan2f(direcao.x, direcao.z) * RAD2DEG;
DrawModelEx(heroi, pos, (Vector3){ 0, 1, 0 }, angulo, (Vector3){ 1, 1, 1 }, WHITE);

// achatar um modelo (efeito de "esmagado")
DrawModelEx(slime, pos, (Vector3){ 0, 1, 0 }, 0, (Vector3){ 1.3f, 0.6f, 1.3f }, WHITE);
```

> Rotação em um único eixo cobre a maioria dos casos (girar em `y` para virar o personagem). Para combinar rotações em vários eixos, como inclinar e girar um avião, monte a matriz com `MatrixRotateXYZ` e atribua à `model.transform` (ver `../transformations.md`)
