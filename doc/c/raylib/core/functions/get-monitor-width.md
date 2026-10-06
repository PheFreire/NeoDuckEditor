**GetMonitorWidth**

> `raylib.h` — módulo `rcore`

O `GetMonitorWidth` devolve a largura de um monitor, em pixels, de acordo com o modo de vídeo que ele está usando agora

```c
int GetMonitorWidth(int monitor);
```

- `monitor`: índice do monitor, de `0` a `GetMonitorCount() - 1`

- Devolve a largura atual do monitor, em pixels
- É a resolução em uso, e não a máxima que o monitor suporta
- Um índice inválido gera um aviso no log e devolve `0`

```c
int m = GetCurrentMonitor();
int largura = GetMonitorWidth(m);
int altura  = GetMonitorHeight(m);

// janela ocupando 80% do monitor
SetWindowSize(largura * 8 / 10, altura * 8 / 10);
```

> Para a largura da **janela**, use o `GetScreenWidth`. O `GetMonitorWidth` é útil para escolher o tamanho da janela ou a resolução do fullscreen, e não para posicionar elementos dentro do jogo (ver `get-screen-width.md`)
