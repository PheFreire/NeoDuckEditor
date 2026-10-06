**IsKeyPressedRepeat**

> `raylib.h` — módulo `rcore`

O `IsKeyPressedRepeat` verifica se uma tecla segurada gerou uma **repetição automática** neste frame. É o mesmo comportamento de um editor de texto: ao segurar uma seta, o cursor anda uma vez, espera um pouco e depois continua andando em intervalos regulares

```c
bool IsKeyPressedRepeat(int key);
```

- `key`: a tecla, como uma constante `KEY_*`

- Devolve `true` nos frames em que o sistema operacional gerou uma repetição da tecla segurada
- **Não** é verdadeiro no primeiro aperto: só nas repetições. Para cobrir os dois, combine com `IsKeyPressed`
- A espera inicial e a velocidade da repetição são as configuradas no sistema operacional

```c
// navegar em um menu: anda um item ao apertar, e continua andando se segurar
if (IsKeyPressed(KEY_DOWN) || IsKeyPressedRepeat(KEY_DOWN)) {
  item = (item + 1) % total_itens;
}
if (IsKeyPressed(KEY_UP) || IsKeyPressedRepeat(KEY_UP)) {
  item = (item - 1 + total_itens) % total_itens;
}
```

---

**Linha do tempo de uma tecla segurada**

```text
tempo:       0 ms   500 ms  533 ms  566 ms  600 ms ...
evento:      aperto  repete  repete  repete  repete
Pressed:     true    -       -       -       -
PressedRep:  -       true    true    true    true
Down:        true    true    true    true    true
```

> Em campos de texto, o Backspace também deve usar a combinação `IsKeyPressed || IsKeyPressedRepeat`, para apagar vários caracteres ao segurar. Os caracteres digitados em si já chegam repetidos pelo `GetCharPressed` (ver `get-char-pressed.md`)
