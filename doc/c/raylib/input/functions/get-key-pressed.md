**GetKeyPressed**

> `raylib.h` — módulo `rcore`

O `GetKeyPressed` devolve o código da próxima tecla apertada neste frame, tirada de uma fila interna. É usado quando o programa precisa saber **qual** tecla foi apertada, sem testar cada uma, como em uma tela de "pressione uma tecla para configurar o controle"

```c
int GetKeyPressed(void);
```

- Devolve o código da tecla (`KEY_*`) e a remove da fila
- Devolve `0` (`KEY_NULL`) quando a fila está vazia
- Se várias teclas foram apertadas no mesmo frame, chame em um laço até receber `0`

```c
// lê todas as teclas apertadas neste frame
int key = GetKeyPressed();
while (key != 0) {
  TraceLog(LOG_INFO, "tecla %d", key);
  key = GetKeyPressed();
}
```

---

**Remapeando controles**

```c
int tecla_pulo = KEY_SPACE;
bool esperando = false;

if (IsKeyPressed(KEY_F1)) esperando = true;   // "pressione a nova tecla de pulo"

if (esperando) {
  int k = GetKeyPressed();
  if (k != 0) {
    tecla_pulo = k;
    esperando = false;
  }
}

if (!esperando && IsKeyPressed(tecla_pulo)) pular();
```

> O `GetKeyPressed` devolve teclas físicas, e não caracteres: apertar Shift+A devolve `KEY_LEFT_SHIFT` e depois `KEY_A`, e não `'A'`. Para texto digitado, use o `GetCharPressed` (ver `get-char-pressed.md`)
