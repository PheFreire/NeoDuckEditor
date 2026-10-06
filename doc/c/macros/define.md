**#define**

> diretiva do pré-processador, não precisa de nenhum header

O `#define` cria uma macro, um nome que o pré-processador substitui por um texto em todo o código abaixo da definição, podendo ser uma constante simples ou uma macro com parâmetros que se parece com uma chamada de função

> O pré-processador roda antes do compilador e trabalha só com texto: ele troca o nome da macro pelo texto definido, sem saber nada sobre tipos ou escopo, e só depois o compilador vê o código resultante

```c
#define NOME texto
#define NOME(param1, param2) texto usando param1 e param2
```

- `NOME`: o nome da macro, por convenção escrito em MAIÚSCULAS para deixar claro que não é uma variável nem uma função
- `texto`: tudo o que vem depois do nome até o fim da linha, que é o que vai ser colado no lugar de cada uso
- `(param1, param2)`: na versão com parâmetros, o `(` precisa vir colado ao nome. Com um espaço (`NOME (x)`) vira uma constante cujo texto começa com `(x)`

- A substituição vale da linha do `#define` até o fim do arquivo (ou até um `#undef`), sem respeitar chaves ou funções
- Não leva `;` no final: o `;` faria parte do texto e seria colado em cada uso
- Nomes dentro de strings (`"TAMANHO"`) e partes de outros nomes (`TAMANHO_MAX`) não são substituídos
- Uma macro pode usar outras macros no seu texto, e elas também são expandidas

---

**Constantes**

```c
#define TAMANHO 100
#define PI 3.14159
#define MENSAGEM "ola mundo"

int buffer[TAMANHO];            // vira: int buffer[100];
double area = PI * r * r;       // vira: double area = 3.14159 * r * r;
printf("%s\n", MENSAGEM);       // vira: printf("%s\n", "ola mundo");
```

Diferente de uma variável `const`, uma constante com `#define` pode ser usada para definir o tamanho de arrays globais e em `case` de `switch`, pois depois do pré-processamento ela é só um número literal

---

**Macros com parâmetros**

Cada parâmetro é trocado pelo texto exato do argumento passado:

```c
#define QUADRADO(x) ((x) * (x))
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

int q = QUADRADO(5);   // vira: int q = ((5) * (5));
int m = MIN(3, 8);     // vira: int m = ((3) < (8) ? (3) : (8));
```

Por não ter tipo, a mesma macro funciona com `int`, `double`, `char` ou qualquer outro tipo que aceite os operadores usados:

```c
double d = MAX(2.5, 1.0); // 2.5
char c = MAX('a', 'z');   // 'z'
```

---

**ARRAY_SIZE**

Uma das macros mais usadas em C, que calcula quantos elementos um array tem dividindo o tamanho total pelo tamanho de um elemento:

```c
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

int nums[] = {10, 20, 30, 40, 50};

for (size_t i = 0; i < ARRAY_SIZE(nums); i++) {
  printf("%d\n", nums[i]);
}
```

> O `ARRAY_SIZE` só funciona com o array de verdade. Se ele tiver sido recebido como parâmetro de função, já virou um ponteiro, e `sizeof(arr)` devolve o tamanho do ponteiro (8 bytes), dando um resultado errado sem nenhum erro de compilação

---

**Macros em mais de uma linha**

Termina-se cada linha com `\` para continuar a definição na linha de baixo:

```c
#define SWAP(a, b) \
  do {             \
    int tmp = (a); \
    (a) = (b);     \
    (b) = tmp;     \
  } while (0)
```

> Diferente de uma função, uma macro não verifica tipos, pode avaliar um argumento mais de uma vez e não aparece no debugger. Por isso, para lógica de verdade, prefira funções (`static inline` se a preocupação for performance) e `const` ou `enum` para constantes, deixando as macros para o que só elas fazem, como `ARRAY_SIZE`, `#` e `##`. As armadilhas de expansão estão em `parenthesis.md`, e o porquê do `do { } while (0)` em `do_while_0.md`
