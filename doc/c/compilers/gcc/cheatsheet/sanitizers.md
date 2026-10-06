**Sanitizers**

> flags `-fsanitize=` do GCC

Sanitizers são verificações que o compilador insere no seu código para detectar, **em tempo de execução**, erros que em C normalmente passam em silêncio: escrever além do fim de um array, usar memória depois do `free`, overflow de inteiro com sinal, etc. Quando o erro acontece, o programa para na hora e imprime exatamente o que houve, onde, e de onde veio a memória envolvida

```bash
gcc -g -O1 -fno-omit-frame-pointer -fsanitize=address,undefined main.c -o main
./main
```

- `-fsanitize=address,undefined`: liga o AddressSanitizer e o UndefinedBehaviorSanitizer juntos
- `-g`: para o relatório mostrar arquivo e linha
- `-O1` ou `-Og`: deixa o programa mais rápido sem perder precisão dos relatórios
- `-fno-omit-frame-pointer`: stack traces mais completos (ver `debugging.md`)
- A flag precisa estar **na compilação e no link**, pois o link adiciona a biblioteca de runtime do sanitizer (`libasan`, `libubsan`)

---

**AddressSanitizer (ASan)** — `-fsanitize=address`

Detecta:
- buffer overflow e underflow no heap, na pilha e em variáveis globais
- use-after-free (acessar memória depois do `free`)
- double free e `free` de ponteiro inválido
- use-after-scope (usar o endereço de uma variável local depois que o bloco dela terminou)
- memory leaks, pelo LeakSanitizer embutido (no Linux, ativo por padrão), relatados no final do programa

Como funciona:
- Para cada 8 bytes de memória do programa, o ASan mantém 1 byte de `shadow memory` dizendo quantos deles podem ser acessados
- O compilador insere antes de **cada** leitura e escrita uma checagem nessa shadow memory
- O runtime substitui `malloc`/`free`: coloca áreas proibidas (`redzones`) em volta de cada bloco e, depois do `free`, deixa a memória em quarentena em vez de reutilizá-la logo, para pegar o use-after-free

```text
 redzone │   bloco de 10 bytes do malloc   │ redzone
  xxxxxx │ ok ok ok ok ok ok ok ok ok ok   │ xxxxxx
                                    buf[10] ┘  → erro: heap-buffer-overflow
```

```c
int *v = malloc(10 * sizeof(int));
v[10] = 1; // ERROR: AddressSanitizer: heap-buffer-overflow ... WRITE of size 4
free(v);
v[0] = 2;  // ERROR: AddressSanitizer: heap-use-after-free
```

- Custo: o programa fica cerca de 2x mais lento e usa cerca de 3x mais memória. Para desenvolvimento e testes, não para produção

---

**UndefinedBehaviorSanitizer (UBSan)** — `-fsanitize=undefined`

Detecta comportamentos indefinidos do padrão C:
- overflow de inteiro com sinal (`INT_MAX + 1`)
- shift inválido (`1 << 32` em um `int`, shift negativo)
- divisão inteira por zero
- dereferência de ponteiro nulo e acesso desalinhado
- índice fora do limite em arrays de tamanho conhecido (`-fsanitize=bounds`, incluído)
- conversão de `float` para `int` fora da faixa, retorno ausente em função não-`void`, etc

```c
int x = INT_MAX;
x++; // runtime error: signed integer overflow: 2147483647 + 1 cannot be represented in type 'int'
```

- Por padrão o UBSan imprime o erro e **continua** a execução. `-fno-sanitize-recover=all` faz o programa abortar no primeiro erro, o que é melhor em testes
- Custo bem menor que o ASan, e importante porque UB é exatamente o tipo de bug que muda de comportamento com otimização (ver `optimization.md`)

---

**Opções de runtime**

```bash
ASAN_OPTIONS=detect_leaks=1:abort_on_error=1 ./main
ASAN_OPTIONS=detect_stack_use_after_return=1 ./main   # retorno de ponteiro para variável local
UBSAN_OPTIONS=print_stacktrace=1 ./main
```

---

**Limitações e armadilhas**

- Só detecta erros que **acontecem** na execução: um overflow em um caminho de código que o teste não percorreu passa despercebido
- O ASan não pode ser combinado com o ThreadSanitizer (`-fsanitize=thread`, para data races). Use builds separados
- Não use junto com Valgrind. Os dois substituem o `malloc`
- Overflows dentro de uma mesma struct ou entre campos de um array de structs não são vistos, pois não há redzone entre eles
- **macOS**: o suporte do GCC a sanitizers é limitado (principalmente em Apple Silicon). O caminho comum é usar o `clang` da Apple, que aceita as mesmas flags. O LeakSanitizer não funciona com o Clang da Apple. Use a ferramenta `leaks --atExit -- ./main`

> Sanitizers não substituem o debugger: eles dizem **onde** e **qual** erro aconteceu, com o stack trace, mas não deixam inspecionar o estado do programa passo a passo. O fluxo comum é rodar com sanitizer para encontrar o erro e depois abrir no GDB/LLDB (com breakpoint em `__asan_report_error` ou `__ubsan_handle_*`, ou com `abort_on_error=1`) para entender por que ele aconteceu
