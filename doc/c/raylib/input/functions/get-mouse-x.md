**GetMouseX**

> `raylib.h` — módulo `rcore`

O `GetMouseX` devolve a posição horizontal do cursor do mouse dentro da janela, em pixels, como inteiro

```c
int GetMouseX(void);
```

- Devolve a coordenada `x` do cursor: `0` na borda esquerda da janela, crescendo para a direita
- Pode ser negativa ou maior que a largura da janela se o cursor estiver fora dela

```c
// barra de volume controlada pela posição horizontal do mouse
if (IsMouseButtonDown(MOUSE_BUTTON_LEFT)) {
  float volume = (float)(GetMouseX() - barra.x) / barra.width;
  if (volume < 0) volume = 0;
  if (volume > 1) volume = 1;
  SetMasterVolume(volume);
}
```

> Para usar as duas coordenadas juntas, o `GetMousePosition` é mais prático, pois devolve um `Vector2` pronto para as funções de colisão e desenho (ver `get-mouse-position.md`)
