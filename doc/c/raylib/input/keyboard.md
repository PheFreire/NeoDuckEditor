**Teclado**

> `raylib.h` — módulo `rcore`

O raylib lê o teclado de duas formas: como **teclas físicas**, identificadas por constantes `KEY_*` (para controles do jogo), e como **caracteres digitados**, em Unicode (para campos de texto). As duas formas existem porque uma tecla não é um caractere: `KEY_A` é a mesma tecla em qualquer layout, mas pode gerar `a`, `A`, `á` ou nada

```c
if (IsKeyDown(KEY_W))     pos.y -= vel * dt;   // tecla física: controle
if (IsKeyPressed(KEY_ESCAPE)) abrir_menu();

int c = GetCharPressed();                       // caractere: digitação
while (c > 0) {
  adicionar_ao_texto(c);
  c = GetCharPressed();
}
```

---

**Funções**

| Função | Devolve |
|--------|---------|
| `IsKeyPressed(key)` | `true` no frame em que a tecla foi apertada |
| `IsKeyPressedRepeat(key)` | `true` a cada repetição automática enquanto a tecla é segurada |
| `IsKeyDown(key)` | `true` enquanto a tecla está apertada |
| `IsKeyReleased(key)` | `true` no frame em que a tecla foi solta |
| `IsKeyUp(key)` | `true` enquanto a tecla está solta |
| `GetKeyPressed()` | o próximo código de tecla da fila, ou `0` |
| `GetCharPressed()` | o próximo caractere Unicode da fila, ou `0` |
| `SetExitKey(key)` | troca a tecla que faz o `WindowShouldClose` devolver `true` |

---

**Constantes de tecla**

- Letras: `KEY_A` a `KEY_Z` (valores iguais ao ASCII maiúsculo: `KEY_A = 65`)
- Números: `KEY_ZERO` a `KEY_NINE`, e no teclado numérico `KEY_KP_0` a `KEY_KP_9`
- Setas: `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`
- Especiais: `KEY_SPACE`, `KEY_ENTER`, `KEY_ESCAPE`, `KEY_BACKSPACE`, `KEY_TAB`, `KEY_DELETE`
- Modificadores: `KEY_LEFT_SHIFT`, `KEY_LEFT_CONTROL`, `KEY_LEFT_ALT`, `KEY_LEFT_SUPER` (Cmd/Windows) e as versões `RIGHT`
- Funções: `KEY_F1` a `KEY_F12`
- `KEY_NULL` (`0`): nenhuma tecla

---

**Tecla física vs caractere**

```text
teclado US:         tecla [Q] → KEY_Q → caractere 'q'
teclado AZERTY:     tecla [A] → KEY_Q → caractere 'a'   (mesma posição física)
Shift + [1]:        KEY_ONE  → caractere '!'
```

- As constantes `KEY_*` representam a **posição** da tecla no layout americano. Um jogo que usa `KEY_W`, `KEY_A`, `KEY_S`, `KEY_D` funciona na mesma posição em qualquer layout
- Para texto, use sempre o `GetCharPressed`: ele já aplica o layout, o Shift, o Caps Lock e os acentos, e devolve o caractere Unicode certo

---

**Combinações com modificadores**

```c
bool ctrl = IsKeyDown(KEY_LEFT_CONTROL) || IsKeyDown(KEY_RIGHT_CONTROL);
bool shift = IsKeyDown(KEY_LEFT_SHIFT) || IsKeyDown(KEY_RIGHT_SHIFT);

if (ctrl && IsKeyPressed(KEY_S)) salvar();
if (ctrl && shift && IsKeyPressed(KEY_Z)) refazer();
```

- O modificador é consultado com `IsKeyDown` (está segurado), e a tecla principal com `IsKeyPressed` (apertada agora)

> Sem foco na janela, nenhuma tecla é recebida (ver `../core/functions/is-window-focused.md`). E por padrão o `Esc` fecha o programa, o que é comum de esquecer em jogos que usam o `Esc` para o menu (ver `functions/set-exit-key.md`)
