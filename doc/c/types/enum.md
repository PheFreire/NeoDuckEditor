**enum**

> palavra-chave da linguagem, não precisa de header

O `enum` cria um tipo com uma lista de constantes inteiras com nome. Cada nome da lista vira uma constante que pode ser usada em qualquer lugar onde um inteiro é esperado, deixando o código mais legível do que números soltos

> Em C, um enum é só um inteiro com nomes. O compilador não impede que uma variável do tipo enum receba um valor fora da lista, então ele serve para dar nome aos valores e para os avisos do compilador, e não como uma barreira de segurança

```c
enum nome {
  CONSTANTE1,
  CONSTANTE2,
  /* ... */
};
```

- `nome`: a tag do enum. O tipo completo é `enum nome`, e não só `nome` (ver `typedef` abaixo)
- `CONSTANTE`: cada valor possível, normalmente escrito em maiúsculas

- A declaração termina com ponto e vírgula depois da `}`, igual à struct
- A primeira constante vale `0` e cada uma das seguintes vale a anterior mais `1`
- A vírgula depois da última constante é permitida (C99), o que facilita adicionar novos valores no fim da lista
- As constantes são do tipo `int`, então no `printf` são impressas com `%d`

---

**Declarando e usando**

```c
enum cor {
  COR_VERMELHO,   // 0
  COR_VERDE,      // 1
  COR_AZUL,       // 2
};

enum cor c = COR_VERDE;

if (c == COR_VERDE) {
  printf("%d\n", c);  // 1
}

c = 42;          // compila sem erro: nada garante que o valor está na lista
int n = COR_AZUL; // a constante é um int comum: n == 2
```

- Uma variável do tipo enum aceita qualquer inteiro, inclusive valores que não estão na lista
- O nome da constante não existe em tempo de execução. Para imprimir `"verde"` em vez de `1` é preciso um array de nomes (ver abaixo)

---

**Valores explícitos**

```c
enum http_status {
  HTTP_OK          = 200,
  HTTP_CRIADO,                // 201: continua contando a partir do anterior
  HTTP_NAO_ACHADO  = 404,
  HTTP_ERRO        = 500,
};

enum resultado {
  RES_ERRO = -1,              // valores negativos são permitidos
  RES_OK,                     // 0
  RES_PADRAO = RES_OK,        // pode repetir um valor e usar constantes anteriores
};
```

- Qualquer constante pode receber um valor com `=`, que precisa ser uma expressão inteira conhecida em tempo de compilação
- Depois de um valor explícito, a contagem continua a partir dele
- Dois nomes com o mesmo valor são permitidos, mas um `switch` não pode ter os dois como `case`, pois seriam casos repetidos

---

**typedef**

```c
typedef enum {
  DIR_CIMA,
  DIR_BAIXO,
  DIR_ESQUERDA,
  DIR_DIREITA,
} Direcao;                  // enum sem tag: só existe pelo nome do typedef

Direcao d = DIR_CIMA;       // sem precisar escrever enum
```

- Funciona exatamente como o `typedef` de uma struct (ver `struct/struct.md`)
- O `typedef` não muda o comportamento, `Direcao` continua aceitando qualquer inteiro

---

**Escopo dos nomes**

```c
enum cor    { VERMELHO, VERDE };
enum fruta  { MACA, VERDE };     // ERRO de compilação: VERDE já foi declarado
```

- As constantes não ficam "dentro" do enum, elas vão para o mesmo escopo onde o enum foi declarado, junto com variáveis e funções
- Por isso dois enums no mesmo escopo não podem ter constantes com o mesmo nome, e uma constante também não pode ter o nome de uma variável ou função
- A convenção é prefixar todas as constantes com o nome do tipo (`COR_VERMELHO`, `FRUTA_VERDE`), o que evita conflitos e deixa claro de onde cada nome vem

---

**enum com switch**

```c
const char *direcao_nome(Direcao d) {
  switch (d) {
    case DIR_CIMA:     return "cima";
    case DIR_BAIXO:    return "baixo";
    case DIR_ESQUERDA: return "esquerda";
    case DIR_DIREITA:  return "direita";
  }
  return "desconhecida";  // para valores fora da lista
}
```

- Com `-Wall`, o GCC e o Clang avisam quando um `switch` sobre um enum não trata todas as constantes (`-Wswitch`)
- Esse aviso só aparece se o `switch` não tiver `default`. Deixar o `default` de fora e tratar o valor inválido depois do `switch` faz o compilador apontar todo `switch` esquecido quando uma constante nova for adicionada

> Essa é a maior vantagem do enum sobre constantes soltas: ao adicionar `DIR_PARADO` na lista, cada `switch` que não trata o novo valor vira um aviso na compilação, em vez de um bug silencioso

---

**Contando os valores**

```c
enum cor {
  COR_VERMELHO,
  COR_VERDE,
  COR_AZUL,
  COR_TOTAL,      // não é uma cor: vale a quantidade de cores (3)
};

int contagem[COR_TOTAL] = {0};  // um contador por cor

for (int i = 0; i < COR_TOTAL; i++) {
  printf("%d\n", contagem[i]);
}
```

- Uma última constante sem valor explícito, depois de constantes que começam em `0` e seguem em sequência, vale exatamente a quantidade de valores anteriores
- Ela acompanha a lista sozinha: adicionar uma cor antes de `COR_TOTAL` aumenta o total automaticamente
- Só funciona se nenhuma constante tiver valor explícito que quebre a sequência

Junto com designated initializers, isso permite um array de nomes que não sai de ordem:

```c
static const char *const cor_nomes[] = {
  [COR_VERMELHO] = "vermelho",
  [COR_VERDE]    = "verde",
  [COR_AZUL]     = "azul",
};

// erro de compilação se alguém adicionar uma cor e esquecer o nome
_Static_assert(sizeof cor_nomes / sizeof cor_nomes[0] == COR_TOTAL, "falta nome de cor");

printf("%s\n", cor_nomes[COR_VERDE]);  // verde
```

> Antes de usar um valor vindo de fora (de um arquivo ou do usuário) como índice, confira se ele está entre `0` e `COR_TOTAL - 1`. Como o enum aceita qualquer inteiro, `cor_nomes[c]` com um `c` inválido lê fora do array

---

**Flags com potências de 2**

```c
enum permissao {
  PERM_LER      = 1 << 0,  // 1
  PERM_ESCREVER = 1 << 1,  // 2
  PERM_EXECUTAR = 1 << 2,  // 4
};

unsigned int p = PERM_LER | PERM_ESCREVER;  // 3: liga as duas

if (p & PERM_ESCREVER) {
  // pode escrever
}

p &= ~PERM_ESCREVER;  // desliga só a escrita
```

- Cada constante ocupa um bit diferente, então várias podem ser combinadas no mesmo inteiro com `|`
- `&` testa se um bit está ligado e `& ~` desliga um bit
- O resultado de uma combinação (`3`) não é nenhuma das constantes da lista, por isso é mais claro guardar as flags em um `unsigned int` do que em uma variável do tipo enum

---

**Tamanho e tipo**

```c
enum cor c;
sizeof c;          // normalmente 4

// C23: tipo fixo escolhido depois dos dois pontos
enum cor_pequena : unsigned char {
  CP_VERMELHO,
  CP_VERDE,
};
sizeof(enum cor_pequena);  // 1
```

- Sem tipo fixo, o compilador escolhe um tipo inteiro que caiba todos os valores. No GCC e no Clang costuma ser `unsigned int` se não houver valores negativos, e `int` se houver, ou seja, 4 bytes
- Como o tamanho depende do compilador, um enum não deve ser gravado direto em formatos de arquivo e protocolos de rede. Converta para um inteiro de tamanho fixo (`uint8_t`, `uint32_t`) antes
- No C23, o tipo depois dos `:` fixa o tamanho do enum e o tipo das constantes

---

**enum, `#define` e `const`**

```c
#define MAX_ITENS 64          // macro: só troca texto, não tem tipo nem escopo
static const int max = 64;    // variável: não serve como tamanho de array global nem como case
enum { MAX_ITENS_E = 64 };    // enum sem nome: constante int de verdade, com escopo
```

- Um enum sem nome é uma forma comum de criar constantes inteiras que respeitam escopo, aparecem com o nome no debugger e podem ser usadas em `case` e no tamanho de arrays
- O `#define` funciona com qualquer tipo (`float`, strings), enquanto o enum só aceita inteiros que caibam em um `int` (antes do C23)
- No C23 existe o `constexpr`, que cria constantes de verdade de qualquer tipo

> Prefira enum sempre que os valores formam um grupo com significado, como estados, tipos de mensagem e direções. O nome do tipo documenta quais valores uma variável deveria ter, o debugger mostra `COR_VERDE` em vez de `1`, e o compilador consegue avisar sobre `switch` incompleto
