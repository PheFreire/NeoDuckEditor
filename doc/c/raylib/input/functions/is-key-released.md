**IsKeyReleased**

> `raylib.h` — módulo `rcore`

O `IsKeyReleased` verifica se uma tecla foi solta **neste frame**. Devolve `true` uma única vez, no frame em que a tecla passou de apertada para solta, e é usado para ações que acontecem ao terminar de segurar

```c
bool IsKeyReleased(int key);
```

- `key`: a tecla, como uma constante `KEY_*`

- Devolve `true` no frame em que a tecla foi solta, e `false` em todos os outros

```c
// carregar um tiro enquanto segura, disparar ao soltar
static float carga = 0;

if (IsKeyDown(KEY_SPACE)) {
  carga += GetFrameTime();
  if (carga > 2.0f) carga = 2.0f;   // carga máxima de 2 segundos
}
if (IsKeyReleased(KEY_SPACE)) {
  atirar(carga);                     // força proporcional ao tempo segurado
  carga = 0;
}
```

---

**Pulo com altura variável**

```c
if (IsKeyPressed(KEY_SPACE) && no_chao) vel_y = -500;
if (IsKeyReleased(KEY_SPACE) && vel_y < 0) vel_y *= 0.5f;   // soltar cedo corta o pulo
```

> Se a janela perder o foco com a tecla apertada, o raylib pode não receber o evento de soltar. Em jogos onde isso importa, trate a perda de foco como se todas as teclas tivessem sido soltas (ver `../../core/functions/is-window-focused.md`)
