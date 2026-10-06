**NDEBUG**

> macro de controle do `assert.h`

O `NDEBUG` ("no debug") é uma macro que, quando está definida no momento do `#include <assert.h>`, faz todo `assert` daquele arquivo virar código vazio. É a forma padrão de manter as asserções durante o desenvolvimento e removê-las da versão final, sem precisar apagar nenhuma linha

```sh
gcc main.c -o programa            # asserts ativos
gcc -DNDEBUG main.c -o programa   # asserts removidos
```

- `-DNDEBUG`: define a macro `NDEBUG` para todos os arquivos daquele comando, como se houvesse `#define NDEBUG 1` no topo de cada um (ver `../compilers/gcc/doc/preprocessor.md`)

---

**O que acontece por baixo**

O `assert.h` define o `assert` de um jeito ou de outro, dependendo do `NDEBUG`:

```c
#ifdef NDEBUG
#define assert(expr) ((void)0)
#else
#define assert(expr) ((expr) ? (void)0 : __assert_fail(#expr, __FILE__, __LINE__, __func__))
#endif
```

```text
código:          assert(b != 0);
sem NDEBUG:      ((b != 0) ? (void)0 : __assert_fail("b != 0", "main.c", 4, __func__));
com NDEBUG:      ((void)0);
```

- Com `NDEBUG`, a expressão **nunca é avaliada**: ela some antes da compilação, junto com qualquer chamada de função ou efeito colateral que estivesse dentro dela
- O `static_assert` não é afetado, pois não existe em tempo de execução (ver `static_assert.md`)

---

**O momento do #include importa**

O `NDEBUG` é verificado **no ponto em que o `assert.h` é incluído**, e não no ponto em que o `assert` é usado:

```c
#define NDEBUG          // precisa vir antes do include
#include <assert.h>
```

```c
#include <assert.h>
#define NDEBUG          // tarde demais: o assert já foi definido como ativo
```

- O `assert.h` é o único header padrão sem include guard, de propósito: incluí-lo de novo depois de definir ou remover o `NDEBUG` redefine o `assert`, permitindo ligar e desligar as asserções em partes diferentes de um mesmo arquivo
- Na prática, é mais simples e seguro controlar pelo comando de compilação (`-DNDEBUG`) do que com `#define` dentro do código

---

**Quando usar**

- **Desenvolvimento e testes**: sem `NDEBUG`. As asserções pegam bugs no ponto exato em que acontecem
- **Versão final (release)**: é comum usar `-DNDEBUG` junto com `-O2`, removendo o custo das verificações
- Otimização **não** define o `NDEBUG` sozinha: `gcc -O2` mantém os `assert` ativos. Ferramentas de build como o CMake adicionam `-DNDEBUG` automaticamente no modo `Release`
- Muitos projetos preferem manter os `assert` ativos também na versão final, pois o custo costuma ser pequeno e um programa que para com uma mensagem clara é melhor que um que continua com dados corrompidos

---

**Armadilhas**

- Qualquer ação dentro do `assert` desaparece com `NDEBUG`:

```c
assert(inicializar() == 0);   // ERRADO: com NDEBUG, inicializar() nunca é chamado

int ok = inicializar();       // certo
assert(ok == 0);
(void)ok;                     // evita o warning de variável não usada quando o assert some
```

- Uma variável usada **só** dentro de um `assert` gera o warning `unused variable` com `NDEBUG`, pois o único uso some. O `(void)variavel;` silencia o aviso sem gerar código
- Testes que dependem de `assert` (ver `unit_tests.md`) nunca devem ser compilados com `NDEBUG`, ou todos passam sem verificar nada

> O mesmo `NDEBUG` pode ser usado para código de depuração próprio, com `#ifndef NDEBUG ... #endif` em volta de verificações mais caras ou de mensagens de log, assim tudo que é só de desenvolvimento é ligado e desligado pela mesma flag
