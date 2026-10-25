**Sanitizers**

> flags `-fsanitize=` do Clang

Os sanitizers nasceram no Clang, e o GCC adotou os mesmos depois, com as mesmas flags e o mesmo formato de relatório. O funcionamento do AddressSanitizer e do UndefinedBehaviorSanitizer, as opções `ASAN_OPTIONS` e as limitações estão em `gcc/cheatsheet/sanitizers.md` e valem igual aqui. Esta nota cobre o que só o Clang tem e o que funciona em cada plataforma

```bash
clang -g -O1 -fno-omit-frame-pointer -fsanitize=address,undefined main.c -o main
```

- Os runtimes dos sanitizers do Clang ficam no `compiler-rt`, dentro de `clang -print-resource-dir` (como `lib/darwin/libclang_rt.asan_osx_dynamic.dylib` no macOS)
- Igual ao GCC, a flag precisa estar na compilação e no link

---

**Suporte por plataforma**

| Sanitizer | Flag | Linux (Clang do LLVM) | macOS (Apple Clang) |
|---|---|---|---|
| AddressSanitizer | `address` | sim | sim |
| UndefinedBehaviorSanitizer | `undefined` | sim | sim |
| ThreadSanitizer | `thread` | sim | sim |
| LeakSanitizer | `leak` | sim (embutido no ASan) | não |
| MemorySanitizer | `memory` | sim | não |
| integer | `integer` | sim | sim |
| nullability | `nullability` | sim | sim |
| SafeStack | `safe-stack` | sim | não |
| Control Flow Integrity | `cfi` | sim, com `-flto` | não |
| libFuzzer | `fuzzer` | sim | não (falta o runtime) |

- No Apple Clang, as flags não suportadas falham com `unsupported option '-fsanitize=memory' for target 'arm64-apple-darwin24.0.0'`
- O `fuzzer` é aceito pelo Apple Clang, mas o link falha porque o `libclang_rt.fuzzer_osx.a` não vem nas Command Line Tools. O Clang do Homebrew traz esse runtime e o do LeakSanitizer (ver `apple-clang.md`)
- No macOS sem LeakSanitizer, use `leaks --atExit -- ./main` para encontrar memory leaks

---

**ThreadSanitizer (TSan)** — `-fsanitize=thread`

Detecta `data races`: duas threads acessando a mesma memória ao mesmo tempo, com pelo menos uma escrevendo, e sem nenhum mutex ou atômico entre elas

```c
static int contador = 0;
static void *inc(void *arg) {
  (void)arg;
  for (int i = 0; i < 100000; i++) contador++;
  return NULL;
}
// main cria duas threads rodando inc e espera as duas com pthread_join
```

```text
WARNING: ThreadSanitizer: data race (pid=78450)
  Write of size 4 at 0x000100688000 by thread T2:
  Previous write of size 4 at 0x000100688000 by thread T1:
SUMMARY: ThreadSanitizer: data race race.c:4 in inc
```

- O relatório mostra as duas threads e a linha de cada acesso. Com `-g`, mostra também a pilha de chamadas de cada uma
- O race é detectado mesmo quando o resultado sai certo naquela execução, porque o TSan observa a falta de sincronização, e não o valor final
- Custo: de 5x a 15x mais lento. Não pode ser combinado com o ASan, então é preciso um build separado

---

**MemorySanitizer (MSan)** — `-fsanitize=memory`, só Linux

Detecta a leitura de memória **não inicializada**: uma variável local sem valor, ou um `malloc` lido antes de ser escrito, quando esse valor decide um `if` ou é passado para uma função

```c
int x;
if (x > 0) {  // WARNING: MemorySanitizer: use-of-uninitialized-value
  /* ... */
}
```

- O ASan não pega esse erro, pois a memória existe e o acesso é válido, só o conteúdo é lixo
- Exige que **todo** o código do programa seja compilado com MSan, inclusive as bibliotecas. Uma biblioteca sem instrumentação faz o MSan acusar falsos positivos nos valores que ela escreveu
- `-fsanitize-memory-track-origins` mostra onde a memória não inicializada foi criada, com o dobro do custo

---

**integer e implicit-conversion**

O `undefined` só pega o que é comportamento indefinido no padrão, como overflow de `signed`. Overflow de `unsigned` e conversões que truncam um valor são definidos pelo C, mas quase sempre são bug:

```c
#include <stdio.h>
int main(void) {
  unsigned u = 0;
  u = u - 1;            // vira 4294967295, definido pelo padrão
  int s = 300;
  unsigned char c = s;  // vira 44, definido pelo padrão
  printf("%u %d\n", u, c);
}
```

```text
uint.c:4:9: runtime error: unsigned integer overflow: 0 - 1 cannot be represented in type 'unsigned int'
uint.c:6:21: runtime error: implicit conversion from type 'int' of value 300 (32-bit, signed) to type 'unsigned char' changed the value to 44 (8-bit, unsigned)
```

- `-fsanitize=integer`: liga `unsigned-integer-overflow`, `implicit-conversion` e outros checks de inteiros
- `-fsanitize=implicit-conversion`: só as conversões que mudam o valor
- Gera falsos positivos em código que usa o overflow de `unsigned` de propósito, como hashes e geradores de números aleatórios. Nesses casos, exclua a função (ver abaixo)

---

**nullability**

```c
static int tamanho(const char *_Nonnull s) { return s[0]; }
int main(int argc, char **argv) {
  const char *p = argc > 5 ? argv[0] : 0;  // NULL só em tempo de execução
  return tamanho(p);
}
```

```text
nn.c:4:18: runtime error: null pointer passed as argument 1, which is declared to never be null
nn.c:1:32: note: _Nonnull type annotation specified here
```

- `_Nonnull` e `_Nullable` são anotações do Clang (ver `extensions.md`). Em tempo de compilação, passar um `NULL` literal já gera o warning `-Wnonnull`
- `-fsanitize=nullability` verifica também os valores que só são `NULL` durante a execução

---

**Modo trap: sem runtime**

```bash
clang -O1 -fsanitize=undefined -fsanitize-trap=undefined main.c -o main
./main    # em vez da mensagem, termina com SIGTRAP (exit 133)
```

- Cada check vira uma instrução de trap direto no código, sem chamar a biblioteca de runtime e sem imprimir nada
- O custo é bem menor e não depende de nenhuma biblioteca, o que permite deixar alguns checks ligados até em produção ou em código de kernel e firmware
- Para saber qual check disparou, abra o programa no debugger: ele para exatamente na instrução de trap

---

**Excluindo código**

```c
__attribute__((no_sanitize("unsigned-integer-overflow")))
uint32_t hash(const char *s) { /* overflow de propósito */ }
```

```bash
# ign.txt
fun:hash
src:third_party/*

clang -fsanitize=integer -fsanitize-ignorelist=ign.txt main.c -o main
```

- `no_sanitize("check")`: desliga um sanitizer só naquela função. `no_sanitize("address")` também existe
- `-fsanitize-ignorelist=arquivo`: exclui funções (`fun:`) ou arquivos inteiros (`src:`) sem mexer no código
- `__has_feature(address_sanitizer)` diz, no preprocessor, se o arquivo está sendo compilado com ASan (ver `extensions.md`)

> Uma combinação comum de builds no CI: um com `address,undefined` (a maior parte dos bugs de memória e UB), um com `thread` para o código com threads e, no Linux, um com `memory`. Os três não podem ser combinados no mesmo binário, mas cada um custa só uma compilação a mais
