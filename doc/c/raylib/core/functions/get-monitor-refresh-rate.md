**GetMonitorRefreshRate**

> `raylib.h` — módulo `rcore`

O `GetMonitorRefreshRate` devolve a taxa de atualização de um monitor, em Hz, ou seja, quantas vezes por segundo ele mostra uma nova imagem. Monitores comuns usam 60 Hz, e monitores para jogos 120, 144 ou 240 Hz

```c
int GetMonitorRefreshRate(int monitor);
```

- `monitor`: índice do monitor, de `0` a `GetMonitorCount() - 1`

- Devolve a taxa de atualização atual, em Hz
- Um índice inválido gera um aviso no log e devolve `0`

```c
InitWindow(800, 450, "jogo");
int hz = GetMonitorRefreshRate(GetCurrentMonitor());
SetTargetFPS(hz > 0 ? hz : 60);   // usa 60 se a taxa não puder ser lida
```

---

**Por que combinar o FPS com o monitor**

```text
monitor 60 Hz, jogo a 90 FPS:

monitor:  |   frame   |   frame   |   frame   |
jogo:     | f1 | f2 | f3 | f4 | f5 | f6 |
                                 └── alguns frames são mostrados, outros descartados
```

- Produzir mais frames que o monitor mostra gasta CPU e GPU sem nenhum ganho visível
- Um FPS que não divide a taxa do monitor faz alguns frames durarem mais que outros, e o movimento parece irregular (judder)
- Com `FLAG_VSYNC_HINT`, a sincronização é feita pela GPU, e o FPS fica limitado à taxa do monitor automaticamente

> Monitores com taxa variável (G-Sync, FreeSync) e taxas fracionárias (59,94 Hz) podem ser informados arredondados. Use o valor como referência para o `SetTargetFPS`, e não para cálculos de tempo, que devem usar o `GetFrameTime`
