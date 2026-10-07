**herança com structs**

> regra da linguagem, baseada na posição do primeiro campo

C não tem herança, mas o padrão garante que um ponteiro para uma struct, convertido com cast, aponta para o seu primeiro campo, e vice-versa. Colocando a struct "base" como primeiro campo da struct "derivada", um ponteiro para a derivada pode ser usado onde se espera um ponteiro para a base

> Como o primeiro campo sempre começa no byte `0`, nunca há padding antes dele, e a struct derivada começa com uma struct base completa. Uma função que recebe a base lê exatamente os mesmos bytes, sem saber que existe algo depois

```c
struct base {
  /* campos da base */
};

struct derivada {
  struct base base;  // precisa ser o primeiro campo
  /* campos extras */
};
```

- `base`: o nome do campo é livre, mas `base` ou `super` deixa a intenção clara
- Os campos da base são acessados por ele: `d.base.campo` ou `ptr->base.campo`

---

**Exemplo**

```c
struct animal {
  const char *nome;
  int idade;
};

struct cachorro {
  struct animal base;
  const char *raca;
};

void animal_mostrar(const struct animal *a) {
  printf("%s, %d anos\n", a->nome, a->idade);
}

struct cachorro rex = {
  .base = {.nome = "rex", .idade = 3},
  .raca = "vira-lata",
};

animal_mostrar(&rex.base);              // forma explícita, sem cast
animal_mostrar((struct animal *)&rex);  // mesmo endereço: base está no offset 0
```

```c
// memória de struct cachorro:
// offset 0   base.nome   ┐
// offset 8   base.idade  │ uma struct animal completa
// offset 12  (padding)   ┘
// offset 16  raca
```

- `animal_mostrar` funciona com qualquer struct que comece com um `struct animal`, como um gato ou um pássaro
- `&rex.base` é preferível ao cast, pois o compilador confere o tipo

---

**Upcast e downcast**

```c
struct cachorro *c = &rex;

struct animal *a = &c->base;                  // upcast: sempre seguro

struct cachorro *de_volta = (struct cachorro *)a;  // downcast: só porque a veio de um cachorro
printf("%s\n", de_volta->raca);              // vira-lata

struct animal generico = {"bicho", 1};
struct cachorro *errado = (struct cachorro *)&generico;
errado->raca;  // comportamento indefinido: lê memória depois de generico
```

- Upcast (derivada → base) é sempre seguro, pois a base começa no offset `0` da derivada
- Downcast (base → derivada) só é válido se o objeto for realmente da derivada. O C não verifica isso, então é comum guardar na base um campo de tipo ou um ponteiro para a vtable, que diz qual é a derivada (ver `polymorphism.md`)

---

**Vários níveis**

```c
struct pastor_alemao {
  struct cachorro base;  // que por sua vez começa com struct animal
  bool treinado;
};

struct pastor_alemao bob = {.base = {.base = {"bob", 5}, .raca = "pastor"}};

animal_mostrar(&bob.base.base);  // pastor_alemao → cachorro → animal
```

- O offset `0` vale em todos os níveis, então um `struct pastor_alemao *` também pode ser convertido direto para `struct animal *`

---

**Base fora do primeiro campo**

Se a base não for o primeiro campo, o cast aponta para o lugar errado. Nesse caso, o `container_of` calcula o início da derivada a partir do endereço do campo (ver `../../macros/struct_macros.md`):

```c
struct gato {
  const char *cor;
  struct animal base;  // não é o primeiro campo
};

void gato_mostrar(struct animal *a) {
  struct gato *g = container_of(a, struct gato, base);  // e não (struct gato *)a
  printf("%s é %s\n", g->base.nome, g->cor);
}
```

- Com o `container_of`, uma mesma struct pode "herdar" de várias bases, uma em cada campo, já que só uma delas pode ser a primeira

> A herança com structs reaproveita campos e funções que só usam a base, mas não muda o comportamento de acordo com a derivada: `animal_mostrar` faz a mesma coisa para um cachorro e para um gato. Para cada derivada ter a sua própria versão de uma função, a herança precisa ser combinada com ponteiros para função (ver `polymorphism.md`)
