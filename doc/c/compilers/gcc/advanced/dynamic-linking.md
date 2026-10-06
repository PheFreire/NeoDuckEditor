**Dynamic linking em detalhe**

> PLT, GOT, lazy binding e carregamento em tempo de execução

Com dynamic linking, o código de uma biblioteca não é copiado para o executável: o linker apenas registra que ela é necessária, e o dynamic loader a carrega e conecta os símbolos quando o programa roda. Isso permite compartilhar a mesma cópia da libc entre todos os processos e atualizar bibliotecas sem recompilar, ao custo de uma indireção em cada chamada e de um trabalho extra na inicialização. Este arquivo aprofunda `../libraries.md`

```bash
readelf -d app | grep NEEDED          # Linux: bibliotecas necessárias
otool -L app                          # macOS
LD_DEBUG=libs,bindings ./app          # Linux (glibc): mostra cada biblioteca e cada símbolo resolvido
```

---

**O que o linker grava no executável**

- `PT_INTERP` / `LC_LOAD_DYLINKER`: qual loader usar (`/lib64/ld-linux-x86-64.so.2`, `/usr/lib/dyld`)
- `DT_NEEDED` / `LC_LOAD_DYLIB`: a lista de bibliotecas necessárias
- `.dynsym`: os símbolos importados e exportados (ver `symbol-table.md`)
- relocations dinâmicas (ver `relocations.md`)
- **PLT** e **GOT**: a estrutura que permite chamar uma função cujo endereço só será conhecido ao executar

---

**PLT e GOT (Linux)**

```text
seu código                 .plt (r-x)                    .got.plt (rw-)
──────────                 ──────────                    ──────────────
call printf@plt  ───────►  printf@plt:                   [printf] ──┐
                             jmp *[printf na GOT] ──────►           │
                                                                    ▼
                                                     antes: volta para o resolver do ld.so
                                                     depois: endereço real de printf na libc
```

- **GOT** (Global Offset Table): tabela de ponteiros no segmento de dados, preenchida pelo loader. O código lê o endereço dela em vez de ter o endereço embutido, então o `.text` não precisa ser alterado
- **PLT** (Procedure Linkage Table): pequenos trechos de código, um por função importada, que fazem um `jmp` indireto através da GOT
- **Lazy binding**: por padrão, a entrada da GOT aponta inicialmente para o resolver do loader. Na **primeira** chamada a `printf`, o resolver encontra o endereço real, grava na GOT e pula para a função. As chamadas seguintes vão direto. Funções nunca chamadas nunca são resolvidas
- **Bind now** (`-Wl,-z,now` ou `LD_BIND_NOW=1`): resolve tudo na inicialização. Com `-Wl,-z,relro,-z,now` (Full RELRO, padrão em várias distros), a GOT fica **somente leitura** depois disso, impedindo que um exploit sobrescreva um ponteiro de função nela
- Com `-fno-plt`, o compilador chama direto via GOT (`call *printf@GOTPCREL(%rip)`), sem passar pela PLT

---

**macOS**

- Chamadas a funções de dylibs passam por `__TEXT,__stubs`, que leem o endereço de `__DATA_CONST,__got` (equivalentes à PLT/GOT)
- Com `chained fixups` (macOS 12+), o `dyld` resolve os binds na inicialização, e o `__DATA_CONST` vira somente leitura em seguida
- **Two-level namespace**: cada import sabe de qual dylib vem. O `dyld` não procura o símbolo em todas as bibliotecas como o `ld.so`
- O `dyld shared cache` já vem pré-linkado, então carregar as bibliotecas do sistema é praticamente só mapear memória

---

**Interposição de símbolos**

No Linux, o loader resolve cada símbolo procurando nas bibliotecas na ordem em que foram carregadas, começando pelo executável. A primeira definição encontrada vence para **todo o processo**:

```bash
gcc -shared -fPIC meu_malloc.c -o libmeu_malloc.so
LD_PRELOAD=./libmeu_malloc.so ./app    # o malloc da sua lib substitui o da libc
```

- É assim que ferramentas de profiling, debuggers de memória e alocadores alternativos (jemalloc, tcmalloc) funcionam sem recompilar o programa
- No macOS, o equivalente é `DYLD_INSERT_LIBRARIES`, ignorado em binários do sistema e em binários com hardened runtime. Por causa do two-level namespace, a substituição também exige `__attribute__((used))` com a section `__DATA,__interpose`

---

**Carregamento manual: dlopen**

```c
#include <dlfcn.h>

void *lib = dlopen("./libplugin.so", RTLD_NOW);
if (!lib) {
  fprintf(stderr, "%s\n", dlerror());
  return 1;
}
int (*iniciar)(void) = (int (*)(void))dlsym(lib, "plugin_iniciar");
iniciar();
dlclose(lib);
```

- Carrega uma biblioteca durante a execução, escolhida em tempo de execução (base de sistemas de plugins)
- Na glibc 2.34+, `dlopen` está na própria libc. Em versões antigas era preciso `-ldl`. No macOS, faz parte da `libSystem`

---

**Custo**

- Cada chamada a uma função externa passa por uma indireção (PLT/stub + leitura da GOT)
- Na inicialização, o loader precisa abrir, mapear e relocar cada biblioteca. Programas com centenas de dependências sentem isso. O prelink do macOS (shared cache) e o `-z now` + menos símbolos exportados (`-fvisibility=hidden`) ajudam

> Diagnóstico rápido no Linux: `LD_DEBUG=help ./app` lista as categorias disponíveis. `LD_DEBUG=symbols ./app` mostra em quais bibliotecas cada símbolo foi procurado. No macOS, `DYLD_PRINT_LIBRARIES=1 ./app` lista as dylibs carregadas (algumas variáveis `DYLD_PRINT_*` foram removidas ou são ignoradas em versões recentes do `dyld`)
