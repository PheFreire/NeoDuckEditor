**static_assert**

> `assert.h` (C11) / palavra-chave da linguagem (C23)

O `static_assert` verifica uma condição durante a **compilação**. Se ela for falsa, o compilador mostra a mensagem como um erro e o executável nem é gerado. Serve para garantir suposições sobre tipos, tamanhos e constantes que, se estiverem erradas, quebrariam o programa de forma silenciosa

```c
static_assert(expressão_constante, "mensagem");
```

- `expressão_constante`: uma expressão que o compilador consegue calcular sozinho, como `sizeof`, `_Alignof`, constantes, valores de `enum` e macros. Variáveis não são permitidas, pois o valor delas só existe com o programa rodando
- `"mensagem"`: uma string literal mostrada no erro de compilação. No C23 passou a ser opcional

- Não gera nenhum código: depois de compilado, não existe nada no executável, então o custo é zero
- Não é afetado por `NDEBUG`, ao contrário do `assert`
- Pode ser usado fora de funções (no escopo global), dentro de funções e dentro de structs

---

**Versões**

| Padrão | Forma |
|--------|-------|
| C11 / C17 | `_Static_assert(expr, "msg")` é a palavra-chave, e `static_assert` é uma macro de `assert.h` que vira `_Static_assert` |
| C23 | `static_assert` é palavra-chave, não precisa de header, e a mensagem é opcional |

- Em C11/C17, usar `static_assert` sem `#include <assert.h>` dá erro. `_Static_assert` funciona sem header em qualquer versão a partir do C11

```c
#include <assert.h>
#include <stdint.h>

static_assert(sizeof(int) == 4, "este código assume int de 4 bytes");
```

```text
main.c:4:1: error: static assertion failed: "este código assume int de 4 bytes"
```

---

**Usos comuns**

Garantir o tamanho de uma struct que é escrita em arquivo ou enviada pela rede, onde qualquer byte de padding a mais muda o formato:

```c
struct cabecalho {
  uint32_t tipo;
  uint32_t tamanho;
};

static_assert(sizeof(struct cabecalho) == 8, "cabecalho deve ter 8 bytes, sem padding");
```

Manter um array sincronizado com um `enum`:

```c
enum cor { VERMELHO, VERDE, AZUL, TOTAL_CORES };

static const char *nomes[] = { "vermelho", "verde", "azul" };

static_assert(sizeof(nomes) / sizeof(nomes[0]) == TOTAL_CORES,
              "falta o nome de alguma cor em 'nomes'");
```

- Se alguém adicionar `AMARELO` ao `enum` e esquecer de adicionar o nome no array, o programa para de compilar, em vez de ler fora do array em tempo de execução

Conferir suposições sobre a plataforma:

```c
#include <limits.h>

static_assert(CHAR_BIT == 8, "este código assume bytes de 8 bits");
static_assert(sizeof(void *) == 8, "este código só funciona em 64 bits");
```

Validar o valor de uma configuração passada com `-D`:

```c
#ifndef TAMANHO_BUFFER
#define TAMANHO_BUFFER 1024
#endif

static_assert(TAMANHO_BUFFER >= 64, "TAMANHO_BUFFER muito pequeno");
static_assert((TAMANHO_BUFFER & (TAMANHO_BUFFER - 1)) == 0,
              "TAMANHO_BUFFER precisa ser potência de 2");
```

---

**static_assert vs #error**

- O `#error` (ver `../macros/error.md`) roda no pré-processador e só enxerga macros e números, sem entender tipos. Não dá para usar `sizeof` em um `#if`
- O `static_assert` roda no compilador e entende tudo que o compilador sabe calcular: `sizeof`, alinhamento, valores de `enum`

> Sempre que uma suposição puder ser verificada na compilação, prefira o `static_assert` ao `assert`: ele pega o problema em qualquer build, mesmo que aquele trecho de código nunca seja executado nos testes, e não tem nenhum custo no programa final
