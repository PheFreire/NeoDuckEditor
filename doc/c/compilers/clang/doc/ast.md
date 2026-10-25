**AST**

> saída do frontend do Clang, base do `clangd`, `clang-tidy` e `clang-format`

A AST (Abstract Syntax Tree) é a árvore que o frontend monta depois de ler o código: cada função, variável, expressão e comando vira um nó, com o tipo de cada expressão já calculado e cada nó ligado à linha e coluna de onde veio. Todo warning do Clang é emitido olhando para essa árvore, e é a partir dela que o LLVM IR é gerado

> Uma árvore de sintaxe é a forma do código depois que o texto foi entendido: em vez de caracteres, ela guarda "uma função `soma` que devolve `int` e cujo corpo é um `return` de uma soma de dois parâmetros". O "abstract" quer dizer que detalhes do texto que não mudam o significado, como espaços e parênteses extras, não aparecem nela

```c
int soma(int a, int b) {
  return a + b;
}
```

```bash
clang -fsyntax-only -Xclang -ast-dump soma.c
```

```text
FunctionDecl <soma.c:1:1, line:3:1> line:1:5 soma 'int (int, int)'
|-ParmVarDecl <col:10, col:14> col:14 used a 'int'
|-ParmVarDecl <col:17, col:21> col:21 used b 'int'
`-CompoundStmt <col:24, line:3:1>
  `-ReturnStmt <line:2:3, col:14>
    `-BinaryOperator <col:10, col:14> 'int' '+'
      |-ImplicitCastExpr <col:10> 'int' <LValueToRValue>
      | `-DeclRefExpr <col:10> 'int' lvalue ParmVar 'a' 'int'
      `-ImplicitCastExpr <col:14> 'int' <LValueToRValue>
        `-DeclRefExpr <col:14> 'int' lvalue ParmVar 'b' 'int'
```

- `-fsyntax-only`: para depois do frontend, sem gerar nenhum arquivo
- `-Xclang -ast-dump`: repassa a opção para o `clang -cc1`, que imprime a árvore. A saída real também mostra o endereço de memória de cada nó e todas as declarações vindas dos headers incluídos
- Cada nó mostra o intervalo do código de onde veio (`<col:10, col:14>`), e as expressões mostram o tipo (`'int'`)

---

**Lendo a árvore**

- `Decl`: declarações, como `FunctionDecl`, `VarDecl`, `ParmVarDecl`, `RecordDecl` (struct), `TypedefDecl`
- `Stmt`: comandos, como `CompoundStmt` (um bloco `{}`), `ReturnStmt`, `IfStmt`, `ForStmt`
- `Expr`: expressões, como `BinaryOperator`, `CallExpr`, `DeclRefExpr` (o uso de um nome já declarado), `IntegerLiteral`
- `ImplicitCastExpr`: uma conversão que o C faz sem estar escrita no código. Aparece em promoções de inteiros, na conversão de array para ponteiro e na leitura do valor de uma variável
- O `LValueToRValue` acima é a leitura do valor de `a`: o nome `a` é um `lvalue` (um lugar na memória), e somar precisa do valor guardado ali

As conversões implícitas que viram bugs (como `int` para `char` e `signed` para `unsigned`) ficam visíveis na AST, mesmo quando não aparecem no código:

```c
unsigned int u = 3;
int x = -1;
return x < u;   // na AST: ImplicitCastExpr 'unsigned int' <IntegralCast> em volta de x
```

---

**Filtrando e imprimindo**

```bash
clang -fsyntax-only -Xclang -ast-dump -Xclang -ast-dump-filter=soma main.c   # só os nós com esse nome
clang -fsyntax-only -Xclang -ast-dump=json soma.c                            # em JSON, para scripts
clang -fsyntax-only -Xclang -ast-print soma.c                                # a árvore de volta para C
clang -fsyntax-only -Xclang -dump-tokens soma.c                              # os tokens antes do parser
```

```text
int 'int'        [StartOfLine]   Loc=<soma.c:1:1>
identifier 'soma' [LeadingSpace] Loc=<soma.c:1:5>
l_paren '('                      Loc=<soma.c:1:9>
```

- `-ast-dump-filter` evita as milhares de linhas que vêm dos headers, como as de `stdio.h`
- `-ast-print` reescreve o código a partir da árvore. Útil para ver como uma macro foi expandida dentro de uma função
- `-dump-tokens` mostra a etapa anterior à AST: o texto dividido em palavras (tokens), cada uma com o tipo e a posição

---

**Por que a AST importa fora do compilador**

Como o Clang foi feito como uma biblioteca, e não só como um programa, outras ferramentas usam o mesmo frontend para ter a mesma AST que o compilador teria:

- `clangd`: o servidor de linguagem (LSP) usado pelos editores. Monta a AST de cada arquivo aberto para dar autocomplete, ir para a definição, renomear e mostrar os erros enquanto você digita
- `clang-tidy`: procura padrões de código com problema percorrendo a AST (ver `static-analysis.md`)
- `clang-format`: formata o código. Usa os tokens, e não a AST completa, por isso funciona até em código que não compila
- `clang --analyze`: o analisador estático, que simula caminhos de execução sobre a AST (ver `static-analysis.md`)

> Para essas ferramentas montarem a AST certa, elas precisam saber as mesmas flags que o compilador usa (`-I`, `-D`, `-std`). Sem isso, um `#include "lista.h"` em outra pasta vira erro no editor mesmo compilando no terminal. É esse o papel do `compile_commands.json` (ver `tooling.md`)
