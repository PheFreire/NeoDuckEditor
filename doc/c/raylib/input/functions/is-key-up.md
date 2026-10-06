**IsKeyUp**

> `raylib.h` — módulo `rcore`

O `IsKeyUp` verifica se uma tecla **não** está apertada. É o contrário exato do `IsKeyDown`

```c
bool IsKeyUp(int key);
```

- `key`: a tecla, como uma constante `KEY_*`

- Devolve `true` enquanto a tecla está solta, e `false` enquanto está apertada
- `IsKeyUp(k)` é sempre igual a `!IsKeyDown(k)`

```c
// o personagem desacelera quando nenhuma tecla de movimento está apertada
if (IsKeyUp(KEY_LEFT) && IsKeyUp(KEY_RIGHT)) {
  vel_x *= 0.9f;   // atrito
}
```

> Na maioria dos casos, `!IsKeyDown(k)` é igualmente legível. O `IsKeyUp` existe para manter a API simétrica com as quatro consultas de cada botão (ver `../input.md`)
