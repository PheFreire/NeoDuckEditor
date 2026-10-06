**GetMonitorCount**

> `raylib.h` — módulo `rcore`

O `GetMonitorCount` devolve quantos monitores estão conectados ao computador. Os índices válidos para as outras funções de monitor vão de `0` a `GetMonitorCount() - 1`

```c
int GetMonitorCount(void);
```

- Devolve a quantidade de monitores conectados
- Precisa da janela criada: antes do `InitWindow`, o resultado não é confiável

```c
InitWindow(800, 450, "monitores");

for (int i = 0; i < GetMonitorCount(); i++) {
  TraceLog(LOG_INFO, "monitor %d: %s %dx%d",
           i, GetMonitorName(i), GetMonitorWidth(i), GetMonitorHeight(i));
}
```

---

**Escolhendo o monitor do jogo**

```c
int alvo = 1;
if (alvo >= GetMonitorCount()) {
  alvo = 0;   // o segundo monitor foi desconectado, volta para o principal
}
SetWindowMonitor(alvo);
```

- `SetWindowMonitor(m)` move a janela para o monitor `m`
- Sempre valide o índice: um monitor salvo nas configurações pode não existir mais na próxima execução

> Ver `../monitor.md` para como os monitores formam uma única área de coordenadas e como centralizar a janela em um deles
