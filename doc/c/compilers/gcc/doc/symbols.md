**Símbolos**

> nomes que o linker enxerga

Um símbolo é um **nome** com um **endereço** associado, guardado na tabela de símbolos de um arquivo objeto: o nome de uma função ou de uma variável global/`static`. É por meio dos símbolos que o linker conecta o uso de uma função em um `.c` à sua definição em outro. Variáveis locais (dentro de funções) não viram símbolos. Elas existem só na pilha ou em registradores

```bash
nm main.o
nm -C app       # -C desfaz o name mangling de C++
nm -u main.o    # mostra só os indefinidos
nm -g main.o    # mostra só os globais (externos)
```

```c
// main.c
int global = 1;                // definido, global, .data
static int interno = 2;        // definido, local, .data
int zerada;                    // definido, global, .bss
extern int de_fora;            // não gera símbolo até ser usado; depois: U
static int auxiliar(void) { return interno; }   // definido, local, .text
int soma(int, int);            // declaração: só gera U se for chamada
int main(void) { return soma(global, de_fora) + auxiliar(); }
```

```text
nm main.o
0000000000000000 D global      D = .data, global
0000000000000004 d interno     d = .data, local (static)
0000000000000000 B zerada      B = .bss, global
0000000000000000 t auxiliar    t = .text, local (static)
0000000000000010 T main        T = .text, global
                 U de_fora     U = undefined
                 U soma        U = undefined
```

**Letras do nm**

| Letra | Significado |
|-------|-------------|
| `T` / `t` | código (`.text`) |
| `D` / `d` | variável inicializada (`.data`) |
| `B` / `b` | variável zerada ou não inicializada (`.bss`) |
| `R` / `r` | dado somente leitura (`.rodata`, ex: `const` global) |
| `U` | indefinido: usado aqui, definido em outro lugar |
| `W` / `w` | weak: pode ser substituído por uma definição normal |
| `C` | common: variável sem inicializador, com `-fcommon` |

- Maiúscula = global (visível para outros arquivos), minúscula = local

**Definidos e indefinidos**

- **Definido**: o arquivo contém o código ou o espaço de memória daquele nome
- **Indefinido** (`U`): o arquivo usa o nome, mas espera que outro arquivo o defina. O linker precisa encontrar **exatamente uma** definição global para cada um

**Globais e locais**

- **Global** (external linkage): o padrão para funções e variáveis fora de funções. Visível para o linker resolver usos em outros arquivos
- **Local** (internal linkage): marcado com `static` fora de funções. Existe no `.o`, mas o linker não o usa para resolver referências de outros arquivos. Dois `.c` podem ter cada um a sua função `static void ajuda(void)` sem conflito
- Regra prática: tudo que não precisa ser usado fora do `.c` deve ser `static`. Evita conflito de nomes, deixa o compilador otimizar melhor e documenta a intenção

**Declaração vs definição**

```c
int soma(int a, int b);          // declaração: "existe uma soma com este tipo"
int soma(int a, int b) { ... }   // definição: gera o símbolo T soma

extern int contador;             // declaração: "existe um contador em algum lugar"
int contador = 0;                // definição: gera o símbolo D contador
```

- O **compilador** só precisa da declaração para gerar a chamada. Ele confia que a definição vai existir
- O **linker** só precisa da definição. Ele não sabe nada sobre tipos
- Por isso declarações vão nos headers (podem se repetir em vários `.c`) e definições vão em um único `.c` (ver `preprocessor.md`)
- Como o linker não conhece tipos, declarar `int soma(int, int)` em um arquivo e definir `double soma(double)` em outro **linka sem erro** e quebra em tempo de execução. Incluir o mesmo header no `.c` que define a função faz o compilador pegar essa diferença

**Armadilhas**

- `int x;` em um header incluído por vários `.c`: até o GCC 9 isso era aceito (`common symbol`, letra `C`), mas a partir do GCC 10 o padrão é `-fno-common`, e isso gera `multiple definition`. O correto é `extern int x;` no header e `int x;` em um único `.c`
- No macOS (Mach-O), todo símbolo C ganha um `_` na frente: a função `soma` aparece como `_soma` no `nm` e nos erros do linker
- Em C++, os nomes são codificados com os tipos dos parâmetros (`_Z4somaii`), o `name mangling`. Para chamar código C a partir de C++, as declarações precisam estar em `extern "C" { ... }`

**Símbolos no executável**

- O executável final também tem uma tabela de símbolos, usada por debuggers e profilers para mostrar nomes de funções. `strip app` remove essa tabela (e o debug info), deixando o binário menor. O programa continua funcionando, mas os stack traces passam a mostrar só endereços
- Bibliotecas compartilhadas têm uma segunda tabela, a de símbolos **dinâmicos** (`nm -D libfila.so` no Linux), que lista o que elas exportam para o loader. `-fvisibility=hidden` junto com `__attribute__((visibility("default")))` controla o que fica exposto

> Para descobrir quem define um símbolo que está faltando: `nm -A *.o *.a 2>/dev/null | grep ' T soma'` mostra o arquivo de cada definição. Se aparecer `U soma` em um `.o` e nenhum `T soma` em lugar nenhum, o arquivo que define `soma` não está sendo compilado ou passado ao linker (ver `common-errors.md`)
