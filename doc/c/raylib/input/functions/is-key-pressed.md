**IsKeyPressed**

> `raylib.h` — módulo `rcore`

O `IsKeyPressed` verifica se uma tecla foi apertada **neste frame**. Devolve `true` uma única vez por aperto, no frame em que a tecla passou de solta para apertada, e é usado para ações que devem acontecer uma vez: pular, atirar, abrir um menu

```c
bool IsKeyPressed(int key);
```

- `key`: a tecla, como uma constante `KEY_*` (`KEY_SPACE`, `KEY_A`, `KEY_ENTER`...)

- Devolve `true` no frame em que a tecla foi apertada, e `false` em todos os outros, mesmo que ela continue segurada
- Não repete enquanto a tecla é segurada (para isso, use `IsKeyPressedRepeat`)

```c
if (IsKeyPressed(KEY_SPACE) && no_chao) {
  vel_y = -400;   // pula uma vez por aperto
}
if (IsKeyPressed(KEY_P)) {
  pausado = !pausado;
}
```

---

**Pressed vs Down**

```c
if (IsKeyDown(KEY_SPACE))    vel_y = -400;   // ERRADO para pulo: aplica todo frame enquanto segura
if (IsKeyPressed(KEY_SPACE)) vel_y = -400;   // certo: aplica uma vez
```

- `IsKeyPressed`: eventos (aconteceu agora)
- `IsKeyDown`: estados (está acontecendo). Ver `is-key-down.md`

> O resultado é calculado comparando o estado da tecla neste frame com o do frame anterior, atualizados no `EndDrawing` (ver `../input.md`). Por isso, consultar o `IsKeyPressed` várias vezes no mesmo frame devolve o mesmo valor
