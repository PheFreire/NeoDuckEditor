**ClearWindowState**

> `raylib.h` — módulo `rcore`

O `ClearWindowState` desliga uma ou mais flags de configuração da janela que estavam ligadas. É o par do `SetWindowState`

```c
void ClearWindowState(unsigned int flags);
```

- `flags`: uma ou mais `ConfigFlags` combinadas com `|`, que serão desligadas

- Não devolve nada
- Desliga só as flags pedidas e mantém as outras como estavam

```c
SetConfigFlags(FLAG_WINDOW_HIDDEN);
InitWindow(800, 450, "jogo");

carregar_recursos();
ClearWindowState(FLAG_WINDOW_HIDDEN);       // mostra a janela

ClearWindowState(FLAG_WINDOW_RESIZABLE);    // trava o tamanho
ClearWindowState(FLAG_VSYNC_HINT);          // desliga o V-Sync
```

---

**Alternando uma flag**

```c
void alternar_flag(unsigned int flag) {
  if (IsWindowState(flag)) ClearWindowState(flag);
  else SetWindowState(flag);
}

if (IsKeyPressed(KEY_T)) alternar_flag(FLAG_WINDOW_TOPMOST);
```

> Internamente, o raylib guarda as flags em um único inteiro e faz `flags &= ~flag` para desligar, a mesma operação de bits usada no `termios` (ver `../../../termios/terminal-attributes.md`). Além de atualizar esse inteiro, a função pede ao sistema de janelas para aplicar a mudança
