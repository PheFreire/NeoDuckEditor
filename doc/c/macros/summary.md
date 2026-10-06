**Pré-processador e macros**

> executado antes do compilador, não precisa de nenhum header

O pré-processador é uma etapa que roda antes da compilação de verdade e trabalha apenas com texto: ele lê as linhas que começam com `#` (diretivas), inclui arquivos, apaga trechos e substitui nomes por outros textos, entregando ao compilador um código C já "expandido", sem nenhuma diretiva

> Uma `macro` é um nome definido com `#define` que o pré-processador troca por um texto toda vez que aparece no código. Essa troca é cega: ela não conhece tipos, escopo nem a sintaxe do C, apenas copia e cola texto, e é daí que vêm tanto o poder quanto as armadilhas das macros

O caminho de um arquivo `.c` até o executável:

```c
// 1. pré-processamento: main.c -> código expandido (sem #include, #define, #if...)
// 2. compilação:        código expandido -> assembly / código objeto (main.o)
// 3. linkagem:          main.o + bibliotecas -> executável
```

- Toda diretiva começa com `#` e ocupa a linha inteira. Para continuar uma diretiva na linha de baixo, termina-se a linha com `\`
- As diretivas não terminam com `;`, pois não são instruções do C
- O resultado do pré-processamento pode ser visto com `gcc -E`, o que é a melhor forma de entender o que uma macro realmente gera

```c
// main.c
#define TAMANHO 10

int arr[TAMANHO];
```

```sh
gcc -E main.c
# ...
# int arr[10];
```

Docs deste diretório:

- `define.md`: constantes e macros com parâmetros
- `parenthesis.md`: armadilhas de expansão (parênteses e argumentos avaliados mais de uma vez)
- `do_while_0.md`: macros com várias instruções
- `undef.md`: apagar ou redefinir uma macro
- `ifdef.md`: compilação condicional com `#ifdef` / `#ifndef`
- `if.md`: compilação condicional com expressões (`#if`, `#elif`, `defined`)
- `include_guard.md`: evitar incluir o mesmo header duas vezes
- `stringify.md`: operador `#`
- `token_pasting.md`: operador `##`
- `variadic.md`: macros com número variável de argumentos
- `predefined.md`: macros que já vêm prontas (`__FILE__`, `__LINE__`, etc)
- `error.md`: `#error` e `#warning`
- `assert.md`: `assert` e `static_assert`
- `struct_macros.md`: `offsetof` e `container_of`

> Diferente de uma função, uma macro não existe no programa compilado: ela some depois do pré-processamento, deixando apenas o texto que gerou. Por isso não é possível colocar um breakpoint nela nem pegar o seu endereço, e os erros de compilação apontam para o código já expandido
