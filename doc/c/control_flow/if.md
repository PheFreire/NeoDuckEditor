**if**

> palavra-chave da linguagem, não precisa de nenhum header

O `if` executa um trecho de código apenas quando uma condição é verdadeira, podendo ser combinado com `else` para executar outro trecho quando ela for falsa, e com `else if` para testar várias condições em sequência

> Em C não existe um tipo booleano obrigatório para condições: qualquer expressão numérica ou ponteiro serve. O valor `0` (ou `NULL`) é considerado falso, e qualquer outro valor, inclusive negativo, é considerado verdadeiro. Os operadores de comparação (`==`, `!=`, `<`, `>`, `<=`, `>=`) e lógicos (`&&`, `||`, `!`) devolvem `1` para verdadeiro e `0` para falso

```c
if (condição) {
  // executado se condição for verdadeira
} else if (outra_condição) {
  // executado se condição for falsa e outra_condição for verdadeira
} else {
  // executado se nenhuma das anteriores for verdadeira
}
```

- `condição`: qualquer expressão escalar (inteiro, ponto flutuante ou ponteiro), sempre entre parênteses
- `else if`: opcional, pode se repetir quantas vezes for necessário. As condições são testadas de cima para baixo e só o primeiro trecho verdadeiro é executado, ignorando o resto
- `else`: opcional, executado quando nenhuma condição anterior foi verdadeira. Sempre fica no final

- As chaves `{}` são opcionais quando o corpo tem apenas um comando, mas omiti-las é uma fonte comum de bugs, pois só o primeiro comando depois do `if` pertence a ele
- O `else if` não é uma palavra-chave própria: é apenas um `else` cujo único comando é outro `if`
- Os operadores `&&` e `||` fazem avaliação de curto-circuito (short-circuit): no `&&`, se o lado esquerdo for falso, o direito nem é avaliado. No `||`, se o lado esquerdo for verdadeiro, o direito nem é avaliado
- Para comparar strings, use `strcmp`, e não `==`, que compara apenas os endereços dos ponteiros

```c
int nota = 75;

if (nota >= 90) {
  printf("A\n");
} else if (nota >= 70) {
  printf("B\n"); // executado, e as condições abaixo nem são testadas
} else if (nota >= 50) {
  printf("C\n");
} else {
  printf("reprovado\n");
}
```

**Usando o próprio valor como condição**

Como `0` e `NULL` são falsos, é comum testar um valor ou ponteiro diretamente, sem comparar:

```c
FILE *file = fopen("dados.txt", "r");
if (!file) { // o mesmo que file == NULL
  perror("fopen");
  return 1;
}

int restantes = 3;
if (restantes) { // o mesmo que restantes != 0
  printf("ainda há %d\n", restantes);
}
```

**Curto-circuito protegendo o acesso**

A ordem das condições importa: com `&&`, o lado direito só é avaliado se o esquerdo for verdadeiro, o que evita acessar um ponteiro nulo ou um índice fora do array:

```c
if (ptr != NULL && ptr->ativo) {
  // ptr->ativo só é lido se ptr não for NULL
}

if (i < total && nums[i] > 0) {
  // nums[i] só é lido se i estiver dentro do array
}
```

**O perigo de omitir as chaves**

Sem `{}`, só o primeiro comando pertence ao `if`, mesmo que a indentação sugira o contrário:

```c
if (erro)
  printf("falhou\n");
  return 1; // NÃO pertence ao if: é executado sempre

// o correto
if (erro) {
  printf("falhou\n");
  return 1;
}
```

**Dangling else**

Quando há `if` aninhados sem chaves, o `else` sempre pertence ao `if` mais próximo dele, independente da indentação:

```c
if (a)
  if (b)
    printf("a e b\n");
else
  printf("?\n"); // pertence ao if (b), e não ao if (a)

// usando chaves para deixar a intenção explícita
if (a) {
  if (b) {
    printf("a e b\n");
  }
} else {
  printf("não a\n");
}
```

**Operador ternário**

Para escolher entre dois valores com base em uma condição, o operador `? :` é uma forma curta de `if` / `else` que devolve um valor:

```c
int maior = (a > b) ? a : b;
printf("%s\n", idade >= 18 ? "adulto" : "menor");
```

> Um erro clássico é usar `=` (atribuição) no lugar de `==` (comparação): `if (x = 5)` atribui `5` a `x` e é sempre verdadeiro. O GCC/Clang com `-Wall` avisam sobre isso. Quando a atribuição dentro do `if` é intencional, como em `if ((n = ler()) > 0)`, deixe a comparação explícita ou use parênteses duplos para indicar a intenção
