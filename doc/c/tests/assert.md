**assert**

> `assert.h`

O `assert` é uma macro que verifica uma condição enquanto o programa roda. Se a condição for verdadeira, nada acontece. Se for falsa, ele escreve no `stderr` qual condição falhou, em qual arquivo, linha e função, e encerra o programa na hora com `abort()`

```c
void assert(scalar expressão);
```

- `expressão`: qualquer valor escalar (inteiro, ponto flutuante ou ponteiro). `0` (ou `NULL`) é falso, qualquer outro valor é verdadeiro

- Não devolve nada
- Verdadeira: não faz nada e o programa continua
- Falsa: escreve a mensagem de erro e chama `abort()`, que encerra o programa imediatamente, sem rodar as funções do `atexit` e sem esvaziar os buffers do `stdio`
- Com `NDEBUG` definido, a macro inteira some do código, inclusive a expressão (ver `ndebug.md`)
- No C23, o `assert` passou a aceitar vírgulas na expressão (como em compound literals), pois virou uma macro variádica

```c
#include <assert.h>

int dividir(int a, int b) {
  assert(b != 0);
  return a / b;
}

int main(void) {
  dividir(10, 0);
  return 0;
}
```

```text
Linux:  programa: main.c:4: dividir: Assertion `b != 0' failed.
        Aborted (core dumped)

macOS:  Assertion failed: (b != 0), function dividir, file main.c, line 4.
        zsh: abort      ./programa
```

**O que acontece por baixo**

O `assert` é uma macro, e não uma função. Uma implementação simplificada:

```c
#define assert(expr) \
  ((expr) ? (void)0 : __assert_fail(#expr, __FILE__, __LINE__, __func__))
```

- `#expr`: transforma a condição em texto (`"b != 0"`), por isso a mensagem mostra exatamente o que foi escrito no código
- `__FILE__`, `__LINE__`, `__func__`: preenchidos pelo compilador com o arquivo, a linha e a função onde o `assert` está (ver `../macros/predefined.md`)
- `__assert_fail`: função interna da libc (o nome muda entre sistemas) que escreve a mensagem e chama `abort()`
- Por ser uma macro, a localização mostrada é a da linha do `assert`, e não a de dentro da libc

**abort e o código de saída**

```text
assert falso
  │  escreve a mensagem no stderr
  ▼
abort()
  │  envia o sinal SIGABRT ao próprio processo
  ▼
processo encerrado   →  código de saída 134 no shell (128 + 6, o número do SIGABRT)
```

- O `echo $?` depois de um `assert` que falhou mostra `134`. Scripts de teste e ferramentas como o `make` tratam qualquer código diferente de `0` como falha
- Dependendo da configuração do sistema, o `abort()` gera um core dump, que permite abrir o estado do programa no momento da falha com o debugger

**Encontrando a causa no debugger**

Como o programa para exatamente no ponto da falha, o debugger mostra a pilha de chamadas que levou até ele:

```sh
gcc -g -O0 main.c -o programa
gdb ./programa      # ou: lldb ./programa
(gdb) run           # para no SIGABRT do assert
(gdb) bt            # mostra a pilha: abort ← __assert_fail ← dividir ← main
(gdb) frame 3       # sobe até o frame de dividir
(gdb) print b       # 0
```

- O `frame` exato depende de quantas funções internas da libc aparecem na pilha. Procure o primeiro frame que é uma função do seu código (ver `../compilers/gcc/cheatsheet/debugging.md`)

**Mensagem junto com a condição**

O `assert` não tem um parâmetro de mensagem, mas uma string literal é sempre verdadeira (é um ponteiro diferente de `NULL`), então ela pode ser adicionada com `&&` sem mudar o resultado:

```c
assert(indice < total && "indice fora do limite");
// Assertion `indice < total && "indice fora do limite"' failed.
```

**Usos comuns**

```c
void lista_adicionar(struct lista *l, int valor) {
  assert(l != NULL);                    // pré-condição: quem chama passa uma lista válida
  assert(l->total <= l->capacidade);    // invariante: a estrutura não está corrompida
  /* ... */
}

int maior = encontrar_maior(v, n);
assert(maior >= v[0]);                  // pós-condição: o resultado faz sentido

switch (estado) {
  case PARADO:  /* ... */ break;
  case ANDANDO: /* ... */ break;
  default:
    assert(0 && "estado desconhecido"); // um caminho que nunca deveria ser alcançado
}
```

- **Pré-condição**: o que precisa ser verdade quando a função começa (argumentos válidos)
- **Invariante**: o que precisa ser sempre verdade em uma estrutura de dados (o total nunca passa da capacidade)
- **Pós-condição**: o que precisa ser verdade quando a função termina (o resultado está correto)
- `assert(0 && "...")`: marca um ponto do código que nunca deveria ser executado

**Armadilhas**

- Nunca coloque uma ação necessária dentro do `assert`: com `NDEBUG`, a expressão inteira some, e a ação junto (ver `ndebug.md`)

```c
assert(fclose(file) == 0);   // ERRADO: com NDEBUG o arquivo nunca é fechado

int r = fclose(file);        // certo: a ação acontece sempre
assert(r == 0);
```

- Expressões com efeito colateral (`assert(i++ < n)`) fazem o programa se comportar diferente com e sem `NDEBUG`
- Como o `abort()` não esvazia os buffers do `stdio`, um `printf` sem `\n` feito logo antes do `assert` pode não aparecer na tela. Para mensagens de depuração, use o `stderr`, que não tem buffer
- Comparar números de ponto flutuante com `==` dentro de um `assert` falha por causa de arredondamento. Use uma tolerância (ver `../math/classification/float_compare.md`)

> O `assert` só detecta o problema quando aquela linha é executada. Tudo que puder ser verificado durante a compilação, como tamanhos de tipos e valores de constantes, deve usar o `static_assert`, que impede o programa errado de existir (ver `static_assert.md`)
