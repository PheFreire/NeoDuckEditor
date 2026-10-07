**polimorfismo com vtable**

> padrão de organização de código, combina `functions.md` e `inheritance.md`

Polimorfismo é uma função que só conhece a struct base chamar a implementação certa de cada derivada. Em C isso é feito com uma vtable: uma struct de ponteiros para função, única por tipo, para onde cada objeto aponta

> Guardar os ponteiros para função dentro de cada objeto funciona, mas gasta 8 bytes por função em cada instância. Como todos os objetos de um mesmo tipo usam as mesmas funções, os ponteiros vão para uma tabela compartilhada e cada objeto guarda só um ponteiro para ela

```c
struct base;

struct base_vtable {
  tipo (*metodo)(const struct base *self);
  /* outros métodos */
};

struct base {
  const struct base_vtable *vt;  // sempre o primeiro campo da base
};

struct derivada {
  struct base base;              // sempre o primeiro campo da derivada
  /* campos extras */
};
```

- A vtable de cada derivada é uma variável `static const` com os ponteiros para as funções daquela derivada
- A chamada é sempre `obj->vt->metodo(obj)`
- Cada implementação recebe um `struct base *` e faz o downcast para a sua derivada, o que é seguro porque só é chamada pela vtable daquela derivada

---

**Exemplo**

```c
#include <stdio.h>

struct forma;

struct forma_vtable {
  const char *nome;
  double (*area)(const struct forma *self);
};

struct forma {
  const struct forma_vtable *vt;
};

// circulo "herda" de forma
struct circulo {
  struct forma base;
  double raio;
};

static double circulo_area(const struct forma *self) {
  const struct circulo *c = (const struct circulo *)self;  // downcast: a vtable garante que é um circulo
  return 3.14159 * c->raio * c->raio;
}

static const struct forma_vtable CIRCULO_VT = {"circulo", circulo_area};

// quadrado "herda" de forma
struct quadrado {
  struct forma base;
  double lado;
};

static double quadrado_area(const struct forma *self) {
  const struct quadrado *q = (const struct quadrado *)self;
  return q->lado * q->lado;
}

static const struct forma_vtable QUADRADO_VT = {"quadrado", quadrado_area};

// funciona com qualquer forma, sem saber qual é
void forma_mostrar(const struct forma *f) {
  printf("%s: %.2f\n", f->vt->nome, f->vt->area(f));
}

int main(void) {
  struct circulo c = {.base = {&CIRCULO_VT}, .raio = 1.0};
  struct quadrado q = {.base = {&QUADRADO_VT}, .lado = 3.0};

  const struct forma *formas[] = {&c.base, &q.base};

  for (size_t i = 0; i < 2; i++) {
    forma_mostrar(formas[i]);  // chama a area certa para cada forma
  }
  return 0;
}
// circulo: 3.14
// quadrado: 9.00
```

```text
c (struct circulo)            CIRCULO_VT
┌──────────────────┐          ┌────────────────────────┐
│ base.vt ─────────┼────────► │ nome = "circulo"       │
│ raio = 1.0       │          │ area = circulo_area    │
└──────────────────┘          └────────────────────────┘

q (struct quadrado)           QUADRADO_VT
┌──────────────────┐          ┌────────────────────────┐
│ base.vt ─────────┼────────► │ nome = "quadrado"      │
│ lado = 3.0       │          │ area = quadrado_area   │
└──────────────────┘          └────────────────────────┘
```

- `forma_mostrar` só conhece `struct forma`. Adicionar um triângulo não exige mudar nada nela, apenas criar a struct, a função de área e a vtable
- A vtable é `static const` e única por tipo, então cada objeto gasta só um ponteiro (`vt`), não importa quantas funções a tabela tenha
- `f->vt->area(f)` é o que o C++ faz por baixo em um método `virtual`: segue o ponteiro até a tabela, pega o endereço da função e passa o objeto como `this`

---

**Construtores**

Uma função que cria o objeto garante que a vtable nunca fica esquecida:

```c
struct circulo circulo_criar(double raio) {
  return (struct circulo){.base = {&CIRCULO_VT}, .raio = raio};
}

struct circulo c = circulo_criar(2.0);
```

- Com a struct opaca, o construtor devolve um ponteiro alocado e quem usa nunca vê a vtable (ver `opaque.md`)

---

**Sobrescrever e reaproveitar métodos**

```c
// quadrado_colorido "herda" de quadrado
struct quadrado_colorido {
  struct quadrado base;
  const char *cor;
};

static const struct forma_vtable QUADRADO_COLORIDO_VT = {
  "quadrado colorido",
  quadrado_area,  // reaproveita a área do quadrado: o offset 0 faz o cast dela funcionar
};
```

- "Sobrescrever" um método é apontar a vtable da derivada para outra função
- Reaproveitar o da base é apontar para a mesma função da vtable da base
- Uma implementação pode chamar a da base explicitamente, como o `super` de outras linguagens: `QUADRADO_VT.area(self)`

---

**Armadilhas**

- Esquecer de preencher o `vt` deixa ele `NULL` (ou lixo), e a primeira chamada derruba o programa
- Apontar o `vt` de um objeto para a vtable de outro tipo compila sem aviso, e o downcast dentro do método passa a ler campos que não existem
- A vtable precisa ser `const`. Se ela puder ser alterada, trocar um ponteiro nela muda o comportamento de todos os objetos daquele tipo ao mesmo tempo

> Essa técnica permite orientação a objetos em C puro, sem nenhuma biblioteca. O custo é que todo o controle fica com o programador: um cast para o tipo errado ou uma vtable esquecida compila sem nenhum aviso e só falha enquanto o programa roda
