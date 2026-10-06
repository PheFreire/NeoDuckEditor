**ToggleFullscreen**

> `raylib.h` — módulo `rcore`

O `ToggleFullscreen` alterna a janela entre o modo janela e o fullscreen exclusivo. Em fullscreen exclusivo, a janela ocupa o monitor inteiro e o monitor muda para a resolução da janela

```c
void ToggleFullscreen(void);
```

- Não recebe parâmetros e não devolve nada
- Se está em janela, entra em fullscreen. Se está em fullscreen, volta para janela
- O monitor passa a usar a **resolução da janela**: uma janela 800x450 em fullscreen muda o monitor para 800x450 (se ele suportar)

```c
if (IsKeyPressed(KEY_F11) || (IsKeyDown(KEY_LEFT_ALT) && IsKeyPressed(KEY_ENTER))) {
  ToggleFullscreen();
}
```

---

**Fullscreen na resolução do monitor**

Para entrar em fullscreen sem mudar a resolução do monitor, ajuste o tamanho da janela antes:

```c
if (IsKeyPressed(KEY_F11)) {
  int m = GetCurrentMonitor();
  if (!IsWindowFullscreen()) {
    SetWindowSize(GetMonitorWidth(m), GetMonitorHeight(m));
    ToggleFullscreen();
  } else {
    ToggleFullscreen();
    SetWindowSize(800, 450);   // volta ao tamanho de janela
  }
}
```

---

**Fullscreen exclusivo vs borderless windowed**

| | `ToggleFullscreen` | `ToggleBorderlessWindowed` |
|---|---|---|
| Resolução do monitor | muda para a da janela | não muda |
| Trocar de janela (Alt+Tab) | lento, pode piscar | instantâneo |
| Desempenho | pode ser um pouco melhor | igual ao modo janela |
| Verificação | `IsWindowFullscreen()` | `IsWindowState(FLAG_BORDERLESS_WINDOWED_MODE)` |

- O borderless windowed é uma janela sem borda do tamanho do monitor. É o modo preferido por muitos jogos modernos, pois não troca a resolução e permite alternar entre programas sem atraso

> No macOS, o fullscreen exclusivo cria um novo "espaço" do sistema e a troca é animada. O borderless windowed costuma ter um comportamento mais previsível nessa plataforma
