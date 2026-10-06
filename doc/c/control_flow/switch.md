**switch**

> palavra-chave da linguagem, não precisa de nenhum header

O `switch` compara o valor de uma expressão inteira com uma lista de constantes (`case`) e pula direto para o trecho de código da que for igual, sendo uma alternativa mais organizada a uma sequência de `if` / `else if` que testam a mesma variável

> Um `case` não é um bloco, e sim um `rótulo` (label): ele marca apenas o ponto onde a execução começa. Depois de entrar em um `case`, o código continua descendo pelos `case` seguintes até encontrar um `break` ou o fim do `switch`

```c
switch (expressão) {
  case CONSTANTE_1:
    // executado se expressão == CONSTANTE_1
    break;
  case CONSTANTE_2:
    // executado se expressão == CONSTANTE_2
    break;
  default:
    // executado se nenhum case for igual
    break;
}
```

- `expressão`: precisa ser de um tipo inteiro (`int`, `char`, `long`, `enum`, etc). `float`, `double`, strings e ponteiros não são aceitos
- `case`: cada valor precisa ser uma constante conhecida em tempo de compilação, como `42`, `'a'`, um `#define` ou um valor de `enum`. Variáveis não são aceitas, e dois `case` não podem ter o mesmo valor
- `default`: opcional, executado quando nenhum `case` corresponde. Pode aparecer em qualquer posição, mas por convenção fica no final
- `break`: sai do `switch` e continua no código logo depois dele

- Se nenhum `case` corresponder e não houver `default`, nada é executado
- Sem o `break`, a execução "cai" (fall through) para o `case` seguinte e executa o código dele também, mesmo que o valor não seja igual
- O compilador costuma transformar um `switch` com muitos `case` em uma tabela de saltos (jump table), indo direto ao trecho certo em vez de testar um valor por vez como em uma cadeia de `if`

```c
int opcao = 2;

switch (opcao) {
  case 1:
    printf("novo jogo\n");
    break;
  case 2:
    printf("carregar jogo\n"); // executado
    break;
  case 3:
    printf("sair\n");
    break;
  default:
    printf("opção inválida\n");
    break;
}
```

**Fall through: esquecendo o break**

Sem o `break`, todos os `case` abaixo do que foi escolhido também são executados:

```c
int n = 1;

switch (n) {
  case 1:
    printf("um\n");   // executado
  case 2:
    printf("dois\n"); // também executado, pois não houve break
  case 3:
    printf("três\n"); // também executado
    break;
  case 4:
    printf("quatro\n");
}
// saída: um, dois, três
```

**Agrupando vários valores no mesmo código**

O fall through pode ser usado de propósito, empilhando vários `case` vazios para que todos executem o mesmo trecho:

```c
char c = 'e';

switch (c) {
  case 'a':
  case 'e':
  case 'i':
  case 'o':
  case 'u':
    printf("vogal\n"); // executado para qualquer um dos cinco
    break;
  default:
    printf("consoante ou outro caractere\n");
    break;
}
```

**Usando com enum**

O `switch` combina bem com `enum`, e o GCC/Clang com `-Wall` avisam quando algum valor do `enum` não foi tratado em nenhum `case` (desde que não haja `default`):

```c
enum estado { PARADO, ANDANDO, CORRENDO };

void mover(enum estado e) {
  switch (e) {
    case PARADO:
      printf("parado\n");
      break;
    case ANDANDO:
      printf("andando\n");
      break;
    case CORRENDO:
      printf("correndo\n");
      break;
  }
}
```

**Declarando variáveis dentro de um case**

Como os `case` são apenas rótulos, declarar uma variável logo após um deles pode dar erro de compilação ou pular a sua inicialização. A solução é abrir um bloco `{}` próprio para o `case`:

```c
switch (opcao) {
  case 1: {
    int total = calcular(); // a variável só existe dentro deste bloco
    printf("%d\n", total);
    break;
  }
  case 2:
    printf("outra opção\n");
    break;
}
```

> Um `break` dentro de um `switch` sai apenas do `switch`, e não de um laço (`for`, `while`) que esteja em volta dele. Já um `continue` dentro do `switch` é aplicado ao laço em volta, pulando para a próxima volta dele. Para sair do laço a partir de um `switch`, use um `return`, uma variável de controle ou um `goto`
