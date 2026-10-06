**GetScreenWidth**

> `raylib.h` — módulo `rcore`

O `GetScreenWidth` devolve a largura atual da área de desenho da janela, em pixels. É o valor usado para posicionar elementos em relação às bordas e ao centro da tela

```c
int GetScreenWidth(void);
```

- Devolve a largura atual da janela, em pixels lógicos
- Muda quando a janela é redimensionada, maximizada ou alterada com `SetWindowSize`

```c
// texto centralizado horizontalmente
const char *titulo = "MEU JOGO";
int largura_texto = MeasureText(titulo, 40);
DrawText(titulo, (GetScreenWidth() - largura_texto) / 2, 100, 40, DARKGRAY);

// elemento ancorado na borda direita
DrawText("v1.0", GetScreenWidth() - 60, 10, 20, GRAY);
```

---

**Screen vs render vs monitor**

| Função | Devolve |
|--------|---------|
| `GetScreenWidth()` | largura da janela em pixels lógicos |
| `GetRenderWidth()` | largura real do framebuffer (maior em telas HighDPI com `FLAG_WINDOW_HIGHDPI`) |
| `GetMonitorWidth(m)` | largura do monitor `m` |

- Desenhe e calcule posições com o `GetScreenWidth`: o raylib converte para o framebuffer real automaticamente

> Use o `GetScreenWidth()` em todo frame, em vez de guardar a largura passada ao `InitWindow` em uma variável. Assim a interface continua correta se a janela mudar de tamanho (ver `is-window-resized.md`)
