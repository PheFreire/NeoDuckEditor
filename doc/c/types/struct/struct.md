**struct**

> palavra-chave da linguagem, não precisa de header

A `struct` agrupa várias variáveis, que podem ser de tipos diferentes, em um único tipo novo. Cada variável dentro dela é um campo (ou membro), e uma variável do tipo da struct guarda todos esses campos juntos, em sequência na memória

> C não tem classes. A struct é a única forma de juntar dados relacionados em um só tipo, e é a base de quase tudo que é "estruturado" em C.

```c
struct nome {
  tipo campo1;
  tipo campo2;
  /* ... */
};
```

- `nome`: a tag da struct. O tipo completo é `struct nome`, e não só `nome` (ver `typedef` abaixo)
- `campo`: cada variável que faz parte da struct, com seu próprio tipo

- A declaração termina com ponto e vírgula depois da `}`. Esquecer ele gera erros confusos na linha seguinte
- Os campos ficam na memória na ordem em que foram declarados, mas o compilador pode inserir bytes vazios (padding) entre eles (ver `padding.md`)
- Uma struct não pode ter um campo do próprio tipo, apenas um ponteiro para ele

---

**Declarando e inicializando**

```c
struct ponto {
  int x;
  int y;
};

struct ponto a = {10, 20};          // pela ordem dos campos
struct ponto b = {.y = 5, .x = 3};  // designated initializers (C99), em qualquer ordem
struct ponto c = {.x = 7};          // campos não citados viram 0: c.y == 0
struct ponto d = {0};               // tudo zerado
struct ponto e;                     // variável local: campos com lixo de memória
```

- Campos não citados em uma inicialização são sempre zerados, inclusive os que ficam no meio
- Uma struct local sem inicializador tem valores indefinidos. Uma struct global ou `static` começa zerada
- No C23, `= {}` também zera tudo

Um compound literal (C99) cria uma struct temporária sem nome, útil para atribuir todos os campos de uma vez ou passar uma struct sem precisar de uma variável:

```c
struct ponto p;
p = (struct ponto){.x = 1, .y = 2};  // depois da declaração, só assim dá para usar chaves

desenhar((struct ponto){3, 4});      // passa uma struct direto para a função
```

> Prefira sempre os designated initializers. Se alguém mudar a ordem dos campos ou adicionar um campo no meio, `{10, 20}` passa a preencher os campos errados sem nenhum aviso, enquanto `{.x = 10, .y = 20}` continua certo

---

**Acessando campos: `.` e `->`**

```c
struct ponto p = {1, 2};
p.x = 10;             // . acessa o campo a partir da struct

struct ponto *ptr = &p;
ptr->y = 20;          // -> acessa o campo a partir de um ponteiro
(*ptr).y = 20;        // exatamente o mesmo que a linha de cima
```

- `ptr->campo` é só um atalho para `(*ptr).campo`
- Os parênteses em `(*ptr).y` são obrigatórios porque o `.` tem precedência maior que o `*`. Sem eles, `*ptr.y` tenta acessar `y` dentro do ponteiro, o que é erro de compilação
- Os acessos podem ser encadeados: `a.b.c`, `a->b->c`, `a->b.c`

---

**typedef**

```c
typedef struct {
  float x;
  float y;
} Vetor;                    // struct sem tag: só existe pelo nome do typedef

Vetor v = {1.0f, 2.0f};     // sem precisar escrever struct

typedef struct no {
  int valor;
  struct no *proximo;       // aqui dentro o nome No ainda não existe
} No;
```

- O `typedef` cria um apelido para o tipo. `struct no` e `No` passam a ser o mesmo tipo
- Tags e nomes de `typedef` vivem em espaços de nomes separados, então `typedef struct ponto ponto` é válido
- Em uma struct que aponta para si mesma a tag é obrigatória, pois o nome do `typedef` só passa a existir depois da `}`

> Sem `typedef`, escrever `struct` em todo lugar deixa claro que o tipo é uma struct. Com `typedef`, o código fica mais curto. As duas formas são corretas, o importante é ser consistente dentro do projeto

---

**Cópia, atribuição e comparação**

```c
struct ponto a = {1, 2};
struct ponto b = a;              // copia todos os campos
b.x = 99;                        // a.x continua 1

a == b;                          // ERRO de compilação: struct não tem ==
memcmp(&a, &b, sizeof a) == 0;   // compila, mas compara também o padding
```

```c
bool ponto_igual(struct ponto a, struct ponto b) {
  return a.x == b.x && a.y == b.y; // o certo é comparar campo a campo
}
```

- A atribuição copia a struct byte a byte (cópia rasa)
- Arrays dentro da struct são copiados inteiros, algo que não acontece com arrays soltos
- Ponteiros dentro da struct são copiados como endereço, então as duas structs passam a apontar para a mesma memória

```c
struct pessoa {
  char nome[20];   // array: copiado junto com a struct
  char *apelido;   // ponteiro: só o endereço é copiado
};

struct pessoa a = {"pato", strdup("patinho")};
struct pessoa b = a;

b.nome[0] = 'P';     // não muda a.nome
b.apelido[0] = 'P';  // muda a.apelido também: os dois apontam para a mesma string
free(a.apelido);     // b.apelido agora aponta para memória liberada
```

> O `memcmp` compara os bytes de padding, que podem ter qualquer valor, então duas structs com os mesmos campos podem ser consideradas diferentes (ver `padding.md`). Ele também falha com `float` (`0.0` e `-0.0` são iguais, mas têm bytes diferentes) e com ponteiros para strings iguais guardadas em endereços diferentes

---

**Passando para funções**

```c
// por valor: a função recebe uma cópia
void mover_copia(struct ponto p) {
  p.x += 1;  // muda só a cópia
}

// por ponteiro: a função altera a struct original
void mover(struct ponto *p) {
  p->x += 1;
}

// ponteiro para const: não copia nada e promete não alterar
double distancia(const struct ponto *a, const struct ponto *b);

// devolvendo uma struct por valor
struct ponto ponto_criar(int x, int y) {
  return (struct ponto){.x = x, .y = y};
}
```

- Por valor, a struct inteira é copiada a cada chamada. Para structs pequenas, como um ponto com dois `float`, isso é barato (até 16 bytes costumam ir direto em registradores no x86-64 e no ARM64)
- Para structs grandes, prefira `const struct x *`, que copia só um endereço
- Devolver uma struct por valor é normal e seguro, ao contrário de devolver um ponteiro para uma variável local

---

**Structs dentro de structs e auto-referência**

```c
struct retangulo {
  struct ponto origem;   // struct dentro de struct: os campos ficam embutidos
  int largura;
  int altura;
};

struct retangulo r = {.origem = {.x = 0, .y = 0}, .largura = 10, .altura = 5};
r.origem.x = 3;

struct no {
  int valor;
  struct no *proximo;    // ponteiro para o próprio tipo: base de listas e árvores
};
```

- Um campo `struct no proximo` (sem o `*`) é impossível, pois a struct teria tamanho infinito
- Duas structs que apontam uma para a outra precisam de uma declaração antecipada:

```c
struct b;                      // declaração antecipada: tipo incompleto

struct a { struct b *outro; }; // ponteiro para tipo incompleto é permitido
struct b { struct a *outro; };
```

---

**Alocação dinâmica**

```c
struct pessoa *p = malloc(sizeof *p);  // sizeof *p evita repetir o tipo
if (p == NULL) {
  return NULL;
}

*p = (struct pessoa){.idade = 25};     // inicializa todos os campos de uma vez
p->idade++;

free(p);
```

- `sizeof *p` continua certo mesmo se o tipo de `p` mudar. O `*p` dentro do `sizeof` não é executado, então não acessa memória nenhuma
- `calloc(1, sizeof *p)` aloca a struct já zerada
- Se a struct tem campos alocados, eles precisam ser liberados antes dela, normalmente em uma função `x_destruir`
- Para alocar a struct e um array de tamanho variável em um único bloco, veja `flexible_array.md`

---

**Tópicos avançados**

Os assuntos que vão além do uso básico de uma struct ficam nesta mesma pasta:

- `padding.md`: alinhamento, padding, `sizeof` e como ordenar os campos para gastar menos memória
- `flexible_array.md`: array sem tamanho no último campo, alocado junto com a struct
- `bit_fields.md`: campos que ocupam só alguns bits
- `opaque.md`: struct opaca, com os campos escondidos no `.c`
- `functions.md`: ponteiros para função dentro de structs e a convenção do `self`
- `inheritance.md`: herança com a struct base como primeiro campo
- `polymorphism.md`: polimorfismo com vtable, juntando funções em structs e herança

> A struct é só um bloco de memória com nomes para cada pedaço. Tudo que aparece nos tópicos avançados, de encapsulamento a polimorfismo, é construído em cima das regras básicas desta nota: a ordem dos campos, a cópia por valor e o acesso por ponteiro
