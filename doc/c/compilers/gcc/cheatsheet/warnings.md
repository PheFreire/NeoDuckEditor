**Warnings**

> flags `-W` do GCC

Warnings são avisos que o compilador emite sobre código que é válido em C, mas provavelmente está errado: variáveis não usadas, comparação entre `signed` e `unsigned`, formatos de `printf` que não batem com os argumentos, etc. Ao contrário de um erro, o warning não impede a compilação, e por isso é fácil ignorá-lo, mas boa parte dos bugs em C aparece primeiro como um warning

```bash
gcc -std=c17 -Wall -Wextra -Wpedantic main.c -o main
```

```text
main.c:5:12: warning: unused variable 'x' [-Wunused-variable]
    5 |     int x = 10;
      |         ^
```

- O nome entre colchetes (`[-Wunused-variable]`) é a flag que controla aquele aviso: use-o para pesquisar, para desligar (`-Wno-unused-variable`) ou para transformar só ele em erro (`-Werror=unused-variable`)

---

**As flags principais**

- `-Wall`: **não** significa "todos os warnings". É um conjunto escolhido pelos desenvolvedores do GCC com avisos úteis e poucos falsos positivos: `-Wunused-variable`, `-Wformat`, `-Wuninitialized`, `-Wparentheses`, `-Wreturn-type`, `-Wsign-compare` (só em C++), etc. O nome ficou histórico. O GCC tem centenas de warnings e a maioria fica fora do `-Wall`
- `-Wextra`: mais um conjunto, um pouco mais exigente: `-Wsign-compare` em C, `-Wunused-parameter`, `-Wmissing-field-initializers`, `-Wimplicit-fallthrough`, etc
- `-Wpedantic`: avisa sobre tudo que não é ISO C no padrão escolhido com `-std`, como extensões GNU. Só faz sentido junto com `-std=cXX`
- `-Werror`: transforma todos os warnings em erros, impedindo a compilação. `-Werror=nome` faz isso só para um warning específico

---

**Warnings importantes fora do -Wall/-Wextra**

- `-Wshadow`: uma variável local esconde outra de mesmo nome de um escopo externo
- `-Wconversion`: conversões implícitas que podem perder valor (`double` → `int`, `long` → `int`). `-Wsign-conversion` faz o mesmo para trocas entre `signed` e `unsigned`. Barulhentos, mas pegam bugs reais
- `-Wformat=2`: checagem mais rígida de `printf`/`scanf`, inclusive strings de formato que não são literais (risco de format string attack)
- `-Wstrict-prototypes`: funções declaradas como `int f()` em vez de `int f(void)`. Em C antes do C23, `()` significa "argumentos não especificados", e não "nenhum argumento"
- `-Wmissing-prototypes`: função global definida sem declaração prévia, normalmente indicando que faltou colocá-la no header ou marcá-la como `static`
- `-Wnull-dereference`: caminhos onde um ponteiro nulo pode ser acessado (depende de otimização)
- `-Wvla`: uso de arrays de tamanho variável, que podem estourar a pilha
- `-Wcast-align`, `-Wdouble-promotion`, `-Wundef`: casts que pioram alinhamento, `float` promovido a `double` sem intenção, `#if` usando macro não definida

---

**Configuração recomendada para desenvolvimento**

```bash
gcc -std=c17 -g3 -Og \
    -Wall -Wextra -Wpedantic \
    -Wshadow -Wconversion -Wformat=2 \
    -Wstrict-prototypes -Wmissing-prototypes \
    main.c -o main
```

- Em projetos próprios, ligar `-Werror` desde o início mantém a base sem warnings acumulados. Em código que outras pessoas vão compilar com outras versões do GCC, prefira deixá-lo só no CI, pois versões novas adicionam warnings e podem quebrar o build

---

**Armadilhas**

- Alguns warnings dependem das análises feitas pelo otimizador: `-Wmaybe-uninitialized` e `-Wnull-dereference` encontram mais problemas com `-O2` do que com `-O0`. Vale compilar de vez em quando com otimização só para ver os avisos
- Warnings podem mudar entre versões: no GCC 14, `implicit-function-declaration`, `implicit-int`, `int-conversion` e `incompatible-pointer-types` deixaram de ser warnings e viraram **erros** por padrão (ver `common-errors.md`)
- Silenciar um warning com cast (`(int)x`) só esconde o problema. Entenda primeiro por que ele aparece

> O Clang aceita praticamente as mesmas flags, e ainda tem `-Weverything`, que liga literalmente todos os warnings (útil para descobrir quais existem, ruim para uso diário). No GCC não há equivalente. Use `gcc --help=warnings` para listar todos
