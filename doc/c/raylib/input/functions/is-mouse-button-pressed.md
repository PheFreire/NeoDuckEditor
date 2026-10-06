**IsMouseButtonPressed**

> `raylib.h` — módulo `rcore`

O `IsMouseButtonPressed` verifica se um botão do mouse foi apertado **neste frame**. Devolve `true` uma vez por clique, e é usado para ações únicas: clicar em um botão da interface, selecionar uma unidade, disparar

```c
bool IsMouseButtonPressed(int button);
```

- `button`: o botão: `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT`, `MOUSE_BUTTON_MIDDLE`, ou os botões extras (`MOUSE_BUTTON_SIDE`, `MOUSE_BUTTON_EXTRA`, `MOUSE_BUTTON_FORWARD`, `MOUSE_BUTTON_BACK`)

- Devolve `true` no frame em que o botão foi apertado, e `false` nos outros, mesmo que ele continue segurado

```c
Rectangle botao = { 300, 200, 200, 50 };

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT) &&
    CheckCollisionPointRec(GetMousePosition(), botao)) {
  iniciar_jogo();
}
```

---

**Clique de botão de interface**

Botões de interface costumam disparar ao **soltar**, e só se o clique começou e terminou sobre eles. Isso deixa o usuário desistir arrastando o mouse para fora:

```c
static bool pressionado = false;
bool sobre = CheckCollisionPointRec(GetMousePosition(), botao);

if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT) && sobre) pressionado = true;
if (IsMouseButtonReleased(MOUSE_BUTTON_LEFT)) {
  if (pressionado && sobre) iniciar_jogo();
  pressionado = false;
}
```

> Com uma `Camera2D`, converta a posição do mouse para o mundo antes de testar colisão com objetos do jogo, mas não com a interface desenhada fora da câmera (ver `../../camera/coordinate-conversion.md`)
