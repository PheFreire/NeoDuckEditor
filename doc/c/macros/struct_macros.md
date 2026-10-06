**offsetof / container_of**

> `stddef.h` (`offsetof`), `container_of` não é padrão e precisa ser definida

O `offsetof` informa a quantos bytes do início de uma struct um campo começa, e o `container_of`, construído em cima dele, faz o caminho inverso: a partir de um ponteiro para um campo, recupera o ponteiro para a struct inteira que contém esse campo

> Os campos de uma struct ficam em sequência na memória, mas não necessariamente colados: o compilador pode inserir bytes vazios entre eles (`padding`) para que cada campo comece em um endereço alinhado ao seu tamanho. Por isso a posição de um campo nem sempre é a soma dos tamanhos dos campos anteriores

```c
size_t offsetof(tipo, campo);

#define container_of(ptr, tipo, campo) \
  ((tipo *)((char *)(ptr) - offsetof(tipo, campo)))
```

- `tipo`: o tipo da struct, como `struct pessoa`
- `campo`: o nome do campo dentro dela
- `ptr`: no `container_of`, um ponteiro para o `campo` dentro de alguma struct do tipo `tipo`

- `offsetof` devolve um `size_t` calculado na compilação, sem custo nenhum enquanto o programa roda
- `container_of` subtrai esse deslocamento do endereço do campo, chegando ao endereço onde a struct começa. O cast para `char *` é o que faz a subtração ser contada em bytes
- O `container_of` vem do kernel do Linux e não existe na biblioteca padrão, por isso precisa ser definido no seu código

---

**offsetof e padding**

```c
#include <stddef.h>

struct exemplo {
  char letra;   // 1 byte
  int numero;   // 4 bytes, precisa começar em um múltiplo de 4
  char outra;   // 1 byte
};

offsetof(struct exemplo, letra);   // 0
offsetof(struct exemplo, numero);  // 4, e não 1: 3 bytes de padding depois de letra
offsetof(struct exemplo, outra);   // 8
sizeof(struct exemplo);            // 12: mais 3 bytes de padding no final
```

```c
// memória de struct exemplo:
// byte:  0     1  2  3   4  5  6  7   8      9  10 11
//        letra [padding] numero        outra  [padding]
```

---

**container_of**

O uso clássico é em listas encadeadas "intrusivas", onde o nó da lista fica dentro da struct de dados, e não o contrário. Assim, uma mesma implementação de lista serve para qualquer tipo, e o `container_of` recupera o dado a partir do nó:

```c
#include <stddef.h>

#define container_of(ptr, tipo, campo) \
  ((tipo *)((char *)(ptr) - offsetof(tipo, campo)))

struct no {
  struct no *proximo;
};

struct pessoa {
  char nome[20];
  int idade;
  struct no link; // o nó da lista fica dentro da pessoa
};

struct pessoa p1 = {"pato", 25};
struct pessoa p2 = {"pata", 30};

p1.link.proximo = &p2.link;
p2.link.proximo = NULL;

// a lista só conhece struct no; container_of devolve a pessoa que contém cada nó
for (struct no *n = &p1.link; n != NULL; n = n->proximo) {
  struct pessoa *p = container_of(n, struct pessoa, link);
  printf("%s %d\n", p->nome, p->idade);
}
// saída:
// pato 25
// pata 30
```

```c
// como container_of(n, struct pessoa, link) encontra a pessoa:
// endereço de p1          = 1000
// offsetof(pessoa, link)  = 24
// n (endereço de p1.link) = 1024
// 1024 - 24               = 1000, o início de p1
```

> Diferente de um ponteiro `void *` guardado no nó, que precisa de uma alocação extra e de um cast sem nenhuma verificação, o `container_of` não usa memória a mais e funciona com qualquer struct. Mas ele confia cegamente no ponteiro recebido, então passar um ponteiro que não está de fato dentro de uma struct do tipo indicado gera um endereço inválido sem nenhum aviso
