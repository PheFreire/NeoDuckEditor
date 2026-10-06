**Modo canônico**

> flag `ICANON` de `c_lflag`

O modo canônico é o modo padrão de um terminal: a entrada é processada **linha por linha**. Enquanto o usuário digita, os caracteres ficam em um buffer dentro da line discipline, onde podem ser editados (Backspace, `Ctrl+U`, `Ctrl+W`). Só quando a linha termina (Enter, ou `Ctrl+D`) ela é liberada para o `read()`. É o que faz um `scanf` ou um `fgets` esperar o Enter, e o que dá edição de linha "de graça" para qualquer programa

```c
term.c_lflag |= ICANON;    // liga o modo canônico (padrão)
term.c_lflag &= ~ICANON;   // desliga: modo não canônico (ver raw-mode.md)
tcsetattr(STDIN_FILENO, TCSAFLUSH, &term);
```

---

**O que acontece enquanto o usuário digita**

```text
tecla        buffer de linha (kernel)    fila de leitura    read()
p            "p"                         ""                 bloqueado
a            "pa"                        ""                 bloqueado
t            "pat"                       ""                 bloqueado
Backspace    "pa"                        ""                 bloqueado
t o          "pato"                      ""                 bloqueado
Enter        ""                    ──►   "pato\n"     ──►   retorna 5
```

- O seu processo não roda **nada** durante a digitação: o `read()` fica bloqueado dentro do kernel, e todo o trabalho de montar e editar a linha é feito pela line discipline
- O Backspace nunca chega ao programa: a line discipline apaga o último caractere do buffer e, com `ECHO` e `ECHOE` ligados, apaga também na tela (ver `local-flags.md`)
- O que o `read()` recebe é a linha **já editada**, terminada com `\n`

---

**Caracteres especiais** (definidos em `c_cc`, ver `control-characters.md`)

| Tecla padrão | Índice | Efeito em modo canônico |
|--------------|--------|-------------------------|
| Backspace (`^?` ou `^H`) | `VERASE` | apaga o último caractere do buffer |
| `Ctrl+U` | `VKILL` | apaga a linha inteira |
| `Ctrl+W` | `VWERASE` | apaga a última palavra (precisa de `IEXTEN`) |
| `Ctrl+D` | `VEOF` | libera o buffer sem adicionar `\n` |
| Enter (`\n`) | — | libera o buffer incluindo o `\n` |
| — | `VEOL`, `VEOL2` | terminadores de linha adicionais (normalmente desativados) |

---

**read() em modo canônico**

- Retorna **no máximo uma linha** por chamada, mesmo que existam várias prontas na fila
- Se o buffer passado ao `read()` for menor que a linha, retorna só o que cabe. O resto fica para o próximo `read()`
- Nunca retorna uma linha incompleta, exceto com `Ctrl+D`

---

**EOF e o Ctrl+D**

O `Ctrl+D` não é um caractere de "fim de arquivo": é um comando para a line discipline **liberar o buffer atual imediatamente**, sem o `\n`:

```text
buffer "pato" + Ctrl+D   → read() retorna 4 ("pato", sem \n)
buffer ""     + Ctrl+D   → read() retorna 0 → o programa interpreta como EOF
```

- Por isso, no meio de uma linha, é preciso apertar `Ctrl+D` **duas vezes** para encerrar a entrada: a primeira libera o que foi digitado, a segunda libera um buffer vazio, e o `read()` devolve `0`
- O `0` é a forma do `read()` dizer "fim de arquivo". `fgets` devolve `NULL` e `getchar` devolve `EOF` por causa dele. O terminal continua aberto e é possível continuar lendo depois

---

**Armadilhas**

- O buffer de linha tem tamanho limitado (4095 caracteres no Linux, `MAX_CANON` = 1024 no macOS). Colar uma linha maior pode truncá-la ou travar até um Enter
- `scanf("%d", &n)` seguido de `fgets` costuma "pular" o `fgets`: o `scanf` consome o número, mas o `\n` da mesma linha fica na fila, e o `fgets` o lê imediatamente. Isso não é bug do terminal, é o `\n` que o modo canônico entregou
- O `Enter` do teclado envia `\r`. Quem o transforma em `\n` é o `ICRNL` de `c_iflag`, e não o modo canônico. Com `ICRNL` desligado e `ICANON` ligado, o Enter não termina a linha (ver `input-flags.md`)

> O modo canônico serve para programas orientados a linhas (shells simples, prompts, `cat`). Editores, jogos, menus com setas e qualquer coisa que reaja a uma tecla sem esperar o Enter precisam desligar o `ICANON` (ver `raw-mode.md`). Shells modernos (bash com readline, zsh) também desligam o modo canônico e implementam a própria edição de linha, com histórico e setas
