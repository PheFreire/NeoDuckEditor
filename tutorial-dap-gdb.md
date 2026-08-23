# DAP + CodeLLDB no Neovim — Tutorial

## Pré-requisitos

- **CodeLLDB** instalado via Mason (`:MasonInstall codelldb` ou automático pelo plugin)
- Executável compilado **com símbolos de debug** (flag `-g`)
- `gcc` ou `clang` disponível no PATH

---

## 1. Compilar com símbolos de debug

Sempre compile com `-g` e sem otimização (`-O0`) para debug preciso:

```bash
gcc -g -O0 -o meu_programa main.c
```

Com Makefile:

```makefile
CC     = gcc
CFLAGS = -g -O0 -Wall

meu_programa: main.c
	$(CC) $(CFLAGS) -o $@ $^
```

---

## 2. Ver todos os comandos disponíveis

Pressione **`<leader>d`** e aguarde ~400ms — um popup aparece com todos os comandos do grupo Debug:

```
  Debug
  c  Start / Continue          b  Toggle Breakpoint
  s  Step Over                 B  Conditional Breakpoint
  i  Step Into                 L  Logpoint
  o  Step Out                  C  Clear All Breakpoints
  l  Run Last
  R  Restart                   u  Toggle UI
  q  Terminate                 e  Eval Expression / Selection
                               r  Open REPL
```

Pressione qualquer letra para executar o comando sem soltar `<leader>d`.

---

## 3. Referência de keymaps

### Fluxo de execução

| Keymap         | Ação                                              |
|----------------|---------------------------------------------------|
| `<leader>dc`   | Iniciar / continuar até o próximo breakpoint      |
| `<leader>ds`   | Step over — avança uma linha (não entra em funções) |
| `<leader>di`   | Step into — entra dentro da função chamada        |
| `<leader>do`   | Step out — sai da função atual                    |
| `<leader>dl`   | Rodar a última configuração usada                 |
| `<leader>dR`   | Reiniciar a sessão                                |
| `<leader>dq`   | Terminar a sessão                                 |

### Breakpoints

| Keymap         | Ação                                              |
|----------------|---------------------------------------------------|
| `<leader>db`   | Ativar/desativar breakpoint na linha atual        |
| `<leader>dB`   | Breakpoint condicional (ex: `i == 5`)             |
| `<leader>dL`   | Logpoint — imprime mensagem sem parar             |
| `<leader>dC`   | Remover todos os breakpoints                      |

### UI e inspeção

| Keymap         | Ação                                                  |
|----------------|-------------------------------------------------------|
| `<leader>du`   | Abrir/fechar toda a UI                                |
| `<leader>de`   | Avaliar expressão sob o cursor (normal) ou seleção (visual) |
| `<leader>dr`   | Abrir REPL para comandos manuais do debugger          |

---

## 4. Fluxo básico de debug

1. Abra o arquivo `.c` no Neovim
2. Posicione o cursor na linha onde quer pausar
3. `<leader>db` — breakpoint ativo aparece na coluna de sinal
4. `<leader>dc` — CodeLLDB inicia, a UI abre automaticamente
5. Informe o caminho do executável quando solicitado (ex: `./meu_programa`)

---

## 5. Exemplos práticos

### Exemplo 1 — Bug de ponteiro nulo

```c
// crash.c
#include <stdio.h>
#include <stdlib.h>

int soma(int *a, int *b) {
    return *a + *b;          // crash se b for NULL
}

int main() {
    int x = 10;
    int *y = NULL;           // bug intencional
    printf("%d\n", soma(&x, y));
    return 0;
}
```

```bash
gcc -g -O0 -o crash crash.c
```

**Debug:**
1. `<leader>db` na linha `return *a + *b`
2. `<leader>dc` → informe `./crash`
3. Painel Scopes mostra `b = 0x0` (NULL)
4. Cursor em `b` → `<leader>de` para avaliar o valor em floating window

---

### Exemplo 2 — Loop com índice errado

```c
// loop.c
#include <stdio.h>

int main() {
    int arr[5] = {10, 20, 30, 40, 50};
    int soma = 0;

    for (int i = 0; i <= 5; i++) {   // bug: deveria ser i < 5
        soma += arr[i];
    }

    printf("Soma: %d\n", soma);
    return 0;
}
```

```bash
gcc -g -O0 -o loop loop.c
```

**Debug:**
1. `<leader>dB` na linha `soma += arr[i]` → condição: `i == 5`
2. `<leader>dc` → para exatamente quando `i` chega ao índice inválido
3. Painel Scopes mostra `i = 5` e o valor lixo de `arr[5]`

---

### Exemplo 3 — Recursão: acompanhar a call stack

```c
// fib.c
#include <stdio.h>

int fib(int n) {
    if (n == 0) return 0;
    if (n == 1) return 1;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    printf("%d\n", fib(10));
    return 0;
}
```

```bash
gcc -g -O0 -o fib fib.c
```

**Debug:**
1. `<leader>db` dentro de `fib()` na linha do `return`
2. `<leader>dc` → para na primeira chamada
3. Painel **Stacks** mostra a call stack com todos os frames e o valor de `n` em cada nível
4. `<leader>ds` / `<leader>di` para acompanhar passo a passo

---

### Exemplo 4 — Logpoint sem recompilar

Adiciona "prints temporários" sem modificar o código:

1. Cursor na linha dentro do loop
2. `<leader>dL` → informe a mensagem, ex: `i={i}, soma parcial={soma}`
3. `<leader>dc` — o programa roda sem parar e imprime no painel Console a cada iteração

---

## 6. Interface da UI

```
┌──────────────────────────────┬─────────────────────────────────────┐
│  SCOPES                      │                                     │
│  ▾ Locals                    │       EDITOR (código fonte)         │
│    x = 10                    │                                     │
│    y = 0x0                   │  5   int soma(int *a, int *b) {     │
│  ▾ Globals                   │  6 ● →   return *a + *b;            │
│                              │  7   }                              │
│  WATCHES                     │                                     │
│  > *a = 10                   │                                     │
│                              │                                     │
│  BREAKPOINTS                 │                                     │
│  ● crash.c:6                 │                                     │
│                              │                                     │
│  STACKS                      │                                     │
│  soma() crash.c:6            │                                     │
│  main() crash.c:13           │                                     │
├──────────────────────────────┴─────────────────────────────────────┤
│  REPL                               │  CONSOLE                     │
│  (lldb) p *b                        │  Stopped at crash.c:6        │
│  (int) $0 = 0                       │  reason: breakpoint          │
└─────────────────────────────────────┴──────────────────────────────┘
```

- `●` = breakpoint ativo
- `→` = linha atual de execução
- Virtual text ao lado do código mostra o valor das variáveis em tempo real

---

## 7. Dicas rápidas

- **Ver todos os comandos**: `<leader>d` + aguardar → popup com todo o grupo Debug
- **Eval rápido**: cursor sobre qualquer variável → `<leader>de`
- **Eval de expressão composta**: selecione `arr[i]` em visual mode → `<leader>de`
- **REPL manual**: `<leader>dr` — digitar expressões LLDB diretamente (ex: `p variavel`, `memory read addr`)
- **Reiniciar rápido**: `<leader>dR` reutiliza a mesma configuração sem pedir o executável novamente
- **Logpoint**: `<leader>dL` é não-intrusivo — sem parar, sem recompilar
