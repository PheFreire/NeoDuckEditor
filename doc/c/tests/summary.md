**assert.h**

> `assert.h`

A `assert.h` é a biblioteca do C para verificar suposições do código. Ela tem duas ferramentas: o `assert`, que confere uma condição enquanto o programa roda e encerra o programa se ela for falsa, e o `static_assert`, que confere uma condição durante a compilação e impede o programa de ser compilado se ela for falsa. É a base mais simples para escrever testes em C, sem nenhuma biblioteca externa

> Uma `asserção` é uma afirmação que o programador faz sobre o código: "aqui este ponteiro nunca é `NULL`", "este índice sempre está dentro do array". Se a afirmação for falsa, existe um bug, e o melhor é o programa parar no ponto exato em que ele foi detectado, em vez de continuar com dados errados e falhar em outro lugar

```c
#include <assert.h>
```

- Não precisa de nenhuma flag de compilação extra, faz parte da biblioteca padrão

**Conteúdo**

| Item | Quando verifica | Ver |
|------|-----------------|-----|
| `assert(condição)` | enquanto o programa roda | `assert.md` |
| `static_assert(condição, "mensagem")` | durante a compilação | `static_assert.md` |
| `NDEBUG` | desliga todos os `assert` | `ndebug.md` |
| testes com `assert` | — | `unit_tests.md` |
| estrutura de projeto e `make test` | — | `project_setup.md` |

**assert não é tratamento de erro**

O `assert` serve para pegar **bugs do programador**, e não para lidar com situações que podem acontecer normalmente:

| Situação | Ferramenta |
|----------|------------|
| a função recebeu `NULL`, mas quem chama sempre deveria passar um ponteiro válido | `assert` |
| um índice calculado pelo próprio programa saiu do array | `assert` |
| o `sizeof` de uma struct mudou e quebra um formato de arquivo | `static_assert` |
| o arquivo que o usuário pediu não existe | `if` + mensagem de erro |
| o `malloc` devolveu `NULL` | `if` + tratamento |
| o usuário digitou uma letra onde se esperava um número | `if` + pedir de novo |

- Erros que dependem do mundo externo (arquivos, rede, memória, entrada do usuário) precisam ser tratados sempre, inclusive na versão final do programa
- Asserções podem ser desligadas com `NDEBUG` (ver `ndebug.md`), então nunca podem ser a única proteção contra algo que acontece em uso normal

**Onde cada verificação acontece**

```text
código-fonte
  │  static_assert   falha → erro de compilação, o executável nem é gerado
  ▼
compilação
  │  NDEBUG definido? → os assert são removidos aqui
  ▼
programa rodando
  │  assert          falha → mensagem no stderr + abort()
  ▼
fim normal
```

> As macros e o pré-processador por trás do `assert` (como o `#` que transforma a condição em texto) estão em `../macros/assert.md`. Para encontrar erros de memória e comportamento indefinido em tempo de execução, que o `assert` não detecta, combine os testes com os sanitizers do compilador (ver `../compilers/gcc/cheatsheet/sanitizers.md`)
