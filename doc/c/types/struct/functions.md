**funções em structs**

> regra da linguagem, usa ponteiros para função

Uma struct não pode conter funções, mas pode conter ponteiros para funções. Assim, cada variável carrega o comportamento que deve ser usado com ela, e esse comportamento é escolhido enquanto o programa roda

> Um ponteiro para função guarda o endereço onde o código de uma função começa. Chamar o ponteiro executa a função para onde ele aponta, então trocar o ponteiro troca a função chamada sem mudar o código que chama

```c
struct nome {
  tipo_retorno (*campo)(parametros);
};
```

- `campo`: o nome do ponteiro dentro da struct
- `parametros` e `tipo_retorno`: a assinatura que a função apontada precisa ter

- Os parênteses em volta de `*campo` são obrigatórios. Sem eles, `int *campo(int)` declara uma função que devolve `int *`, e não um ponteiro
- O nome de uma função, sozinho, já é o endereço dela, então `s.campo = somar` e `s.campo = &somar` são iguais
- A chamada é feita como uma função normal: `s.campo(1, 2)` ou `ptr->campo(1, 2)`

---

**Tabela de operações**

```c
struct operacao {
  const char *simbolo;
  int (*aplicar)(int a, int b);
};

int somar(int a, int b) { return a + b; }
int multiplicar(int a, int b) { return a * b; }

struct operacao ops[] = {
  {"+", somar},
  {"*", multiplicar},
};

for (size_t i = 0; i < 2; i++) {
  printf("3 %s 4 = %d\n", ops[i].simbolo, ops[i].aplicar(3, 4));
}
// 3 + 4 = 7
// 3 * 4 = 12
```

- Adicionar uma operação é só adicionar uma linha na tabela, sem `switch` e sem mexer no laço

---

**typedef para o ponteiro**

```c
typedef int (*Operador)(int, int);

struct operacao {
  const char *simbolo;
  Operador aplicar;  // mesmo tipo que int (*aplicar)(int, int)
};

Operador escolher(char c);  // sem typedef: int (*escolher(char c))(int, int)
```

- O `typedef` vale mais ainda quando uma função recebe ou devolve um ponteiro para função, onde a sintaxe sem ele fica quase ilegível

---

**self no lugar de this**

C não tem `this`. Para a função mexer na struct que a contém, a struct precisa ser passada explicitamente como argumento, por convenção o primeiro, chamado `self`:

```c
typedef struct contador Contador;

struct contador {
  int valor;
  void (*incrementar)(Contador *self);
  void (*mostrar)(const Contador *self);
};

static void contador_incrementar(Contador *self) {
  self->valor++;
}

static void contador_mostrar(const Contador *self) {
  printf("valor: %d\n", self->valor);
}

Contador contador_criar(void) {
  return (Contador){
    .valor = 0,
    .incrementar = contador_incrementar,
    .mostrar = contador_mostrar,
  };
}

Contador c = contador_criar();
c.incrementar(&c);  // a struct aparece duas vezes: em c.incrementar e em &c
c.mostrar(&c);      // valor: 1
```

- O `typedef struct contador Contador` antes da struct permite usar `Contador` nos parâmetros dos ponteiros, dentro da própria struct
- As funções apontadas podem ser `static`, pois são acessadas pelo ponteiro e não pelo nome, o que deixa elas invisíveis fora do `.c`
- `self` recebe `const` nas funções que só leem, assim como um método `const`
- Trocar o ponteiro de uma variável muda o comportamento só dela: `c.mostrar = outra_funcao`

---

**Callbacks**

Um ponteiro para função em uma struct também serve para avisar quem usa quando algo acontece, junto com um `void *` para levar dados de volta:

```c
struct botao {
  const char *texto;
  void (*ao_clicar)(void *dados);  // quem criou o botão decide o que acontece
  void *dados;                     // repassado sem mudança para ao_clicar
};

void botao_clicar(struct botao *b) {
  if (b->ao_clicar != NULL) {
    b->ao_clicar(b->dados);
  }
}

static void somar_clique(void *dados) {
  int *cliques = dados;
  (*cliques)++;
}

int cliques = 0;
struct botao ok = {.texto = "ok", .ao_clicar = somar_clique, .dados = &cliques};
botao_clicar(&ok);  // cliques == 1
```

- O `void *dados` deixa o callback acessar qualquer coisa, sem a struct precisar conhecer o tipo

---

**Armadilhas**

- Chamar um ponteiro de função `NULL` ou não inicializado derruba o programa com segmentation fault. Inicialize todos os ponteiros ou verifique antes de chamar
- Converter uma função para um ponteiro com outra assinatura compila com um cast, mas chamar por esse ponteiro é comportamento indefinido
- A cópia de uma struct copia os ponteiros, então a cópia continua chamando as mesmas funções

> Guardar os ponteiros dentro de cada variável gasta 8 bytes por função em cada instância, mesmo quando todas apontam para as mesmas funções. Quando o conjunto de funções é sempre o mesmo para um mesmo tipo de objeto, os ponteiros vão para uma tabela compartilhada, a vtable (ver `polymorphism.md`)
