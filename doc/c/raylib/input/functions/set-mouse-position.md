**SetMousePosition**

> `raylib.h` — módulo `rcore`

O `SetMousePosition` move o cursor do mouse para uma posição dentro da janela

```c
void SetMousePosition(int x, int y);
```

- `x`: nova posição horizontal, em pixels da janela
- `y`: nova posição vertical, em pixels da janela

- Não devolve nada
- O cursor do sistema é movido de verdade: o usuário vê o ponteiro pular para a nova posição

```c
// ao abrir um menu, coloca o cursor sobre o primeiro botão
SetMousePosition((int)(botao_jogar.x + botao_jogar.width / 2),
                 (int)(botao_jogar.y + botao_jogar.height / 2));
```

> Mover o cursor sem o usuário esperar costuma ser desconfortável. Para controlar uma câmera pelo movimento do mouse, não recentralize o cursor manualmente a cada frame: use o `DisableCursor`, que faz isso de forma correta pelo sistema operacional (ver `../../core/functions/disable-cursor.md`)
