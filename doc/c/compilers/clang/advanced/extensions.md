**Extensões do Clang**

> macros, builtins e atributos que não fazem parte do padrão C

Além das extensões GNU, que o Clang aceita quase todas (`__attribute__((...))`, `typeof`, statement expressions, `__builtin_expect`), ele tem extensões próprias: macros para descobrir em tempo de compilação o que o compilador suporta, builtins que expõem recursos do LLVM e atributos que dão ao compilador mais informação sobre o código. Código que usa essas extensões só compila no Clang, então elas costumam ficar atrás de um `#if`

---

**Identificando o compilador**

```c
#if defined(__clang__)
  // Clang, Apple Clang ou outro compilador baseado no Clang
#elif defined(__GNUC__)
  // GCC de verdade
#endif
```

```text
#define __clang__ 1
#define __clang_major__ 16
#define __clang_minor__ 0
#define __clang_patchlevel__ 0
#define __apple_build_version__ 16000026
#define __GNUC__ 4
#define __llvm__ 1
```

- O Clang define `__GNUC__` (com o valor `4`, de GCC 4.2.1) para que código feito para o GCC aceite o Clang. Por isso o teste de `__clang__` precisa vir **antes** do de `__GNUC__`
- `__apple_build_version__` só existe no Apple Clang, e `__clang_major__` nele segue a numeração da Apple (ver `apple-clang.md`)
- Comparar versões é frágil. Prefira testar o recurso que você quer usar (abaixo)

---

**Testando recursos: __has_***

```c
#if defined(__has_builtin) && __has_builtin(__builtin_add_overflow)
  // o builtin existe
#endif

#if __has_attribute(overloadable)
  // o atributo existe
#endif

#if __has_feature(address_sanitizer)
  // compilando com -fsanitize=address
#endif

#if __has_include(<threads.h>)
  #include <threads.h>
#else
  // o macOS não tem threads.h: usar pthread.h
#endif
```

- `__has_builtin`, `__has_attribute` e `__has_include` também existem no GCC moderno (e o `__has_include` virou padrão no C23)
- `__has_feature` e `__has_extension` são do Clang. Os nomes mais úteis: `address_sanitizer`, `thread_sanitizer`, `memory_sanitizer`, `c_static_assert`, `c_atomic`
- Testar o recurso é mais robusto que testar a versão, pois funciona igual no Clang do LLVM, no Apple Clang e em versões futuras

---

**Builtins úteis**

```c
int r;
if (__builtin_add_overflow(a, b, &r)) {   // também: __builtin_sub_overflow, __builtin_mul_overflow
  // a + b não cabe em um int
}
```

- Os `__builtin_*_overflow` fazem a conta e devolvem `true` se ela estourou, sem comportamento indefinido. Existem no GCC também

```c
struct pessoa { const char *nome; int idade; double altura; };
struct pessoa p = {"Ana", 30, 1.65};
__builtin_dump_struct(&p, printf);
```

```text
struct pessoa {
  const char * nome = "Ana"
  int idade = 30
  double altura = 1.650000
}
```

- `__builtin_dump_struct` imprime todos os campos de uma struct usando a função passada (`printf` ou uma com a mesma assinatura). É só do Clang e é útil para depurar sem um debugger

```c
int quarto(int x) {
  __builtin_assume(x > 0);
  return x / 4;
}
```

```text
sem o assume                        com o assume
    add  w8, w0, #3                     lsr  w0, w0, #2
    cmp  w0, #0                         ret
    csel w8, w8, w0, lt
    asr  w0, w8, #2
    ret
```

- `__builtin_assume(cond)`: promete ao otimizador que a condição é verdadeira. Aqui, sabendo que `x` é positivo, a divisão vira um shift, sem a correção para negativos
- Se a promessa for falsa em tempo de execução, o comportamento é indefinido. Use só quando a condição já foi garantida antes. `__builtin_unreachable()` é a versão para "este ponto nunca é alcançado", e existe no GCC também

---

**Atributos do Clang**

```c
// overloadable: sobrecarga de funções em C, escolhida pelo tipo dos argumentos
static int    maximo(int a, int b)       __attribute__((overloadable)) { return a > b ? a : b; }
static double maximo(double a, double b) __attribute__((overloadable)) { return a > b ? a : b; }

maximo(1, 2);      // chama a versão int
maximo(1.5, 0.5);  // chama a versão double
```

- O C não tem sobrecarga, e o `_Generic` do C11 é a forma padrão de imitar isso. O `overloadable` é mais simples, mas só existe no Clang

```c
// diagnose_if: um erro ou warning próprio quando a chamada tem um valor constante inválido
static int dobra(int x)
    __attribute__((diagnose_if(x < 0, "x nao pode ser negativo", "error"))) {
  return x * 2;
}

dobra(-1);  // error: x nao pode ser negativo
```

- A condição é verificada só quando o argumento é conhecido na compilação. Com uma variável, nada é verificado

```c
// nullability: documenta e verifica quais ponteiros podem ser NULL
size_t tamanho(const char *_Nonnull s);
char *_Nullable procura(const char *_Nonnull s, char c);
```

- `_Nonnull`: o ponteiro nunca é `NULL`. Passar um `NULL` literal gera `-Wnonnull`, e `-fsanitize=nullability` verifica em tempo de execução (ver `sanitizers.md`)
- `_Nullable`: pode ser `NULL`, e quem usa precisa verificar
- Os headers do SDK da Apple usam essas anotações em todas as funções

```c
// ext_vector_type: vetores com operações elemento a elemento
typedef float vec4 __attribute__((ext_vector_type(4)));

vec4 v = {1, 2, 3, 4};
vec4 w = v * 2;        // {2, 4, 6, 8}, uma instrução NEON/SSE
float x = w.x;         // acesso por nome: .x .y .z .w ou .r .g .b .a
```

- O GCC tem o `vector_size`, parecido, mas sem o acesso por `.x`/`.y`, que vem das linguagens de shader

---

**Blocks**

```c
int (^soma)(int, int) = ^(int a, int b) { return a + b; };
soma(2, 3);  // 5
```

- `Blocks` são funções anônimas que capturam as variáveis do escopo onde foram criadas, como uma closure. São uma extensão da Apple, usadas nas APIs do macOS (como o Grand Central Dispatch)
- Ligados por padrão no macOS. Em outros sistemas precisam de `-fblocks` e de um runtime (`libBlocksRuntime`), senão o erro é `blocks support disabled - compile with -fblocks`
- Para código portável, o padrão continua sendo um ponteiro de função mais um `void *` com o contexto

> Antes de usar uma extensão, verifique se existe uma forma padrão: `_Generic` no lugar do `overloadable`, `static_assert` no lugar de truques com macros, `stdckdint.h` (C23, com `ckd_add`) no lugar do `__builtin_add_overflow`. Quando a extensão for mesmo necessária, deixe-a atrás de `__has_attribute` ou `__has_builtin` com uma alternativa no `#else`, para o código continuar compilando no GCC
