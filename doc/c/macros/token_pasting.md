**Operador ##**

> diretiva do pré-processador, não precisa de nenhum header

O operador `##`, usado dentro de uma macro, junta dois pedaços de texto em um único nome (token), permitindo gerar nomes de variáveis, funções e tipos a partir dos argumentos da macro

> Um `token` é a menor unidade que o compilador entende: um nome (`contador`), um número (`42`), um operador (`+=`) ou um símbolo (`{`). Escrever `a b` gera dois tokens. `a ## b` cola os dois em um só, `ab`

```c
#define NOME(a, b) a ## b
```

- `a ## b`: junta o texto de `a` com o de `b`, removendo qualquer espaço entre eles
- Pode ser usado várias vezes na mesma macro, e com texto fixo de um dos lados (`prefixo_ ## nome`)
- O resultado precisa ser um token válido: juntar `x` com `1` gera `x1`, mas juntar `x` com `+` não gera nada válido e é um erro

```c
#define JUNTAR(a, b) a ## b

int JUNTAR(valor, 1) = 10; // int valor1 = 10;
JUNTAR(pr, intf)("oi\n");  // printf("oi\n");
```

---

**Gerando funções para vários tipos**

Como C não tem templates nem generics, o `##` é a forma de escrever uma vez só uma função que precisa existir para vários tipos:

```c
#define DEFINIR_MAX(tipo)                 \
  tipo max_ ## tipo(tipo a, tipo b) {     \
    return a > b ? a : b;                 \
  }

DEFINIR_MAX(int)    // gera: int max_int(int a, int b) { ... }
DEFINIR_MAX(double) // gera: double max_double(double a, double b) { ... }

int m1 = max_int(3, 7);         // 7
double m2 = max_double(1.5, 0.5); // 1.5
```

---

**Gerando uma struct de lista para cada tipo**

```c
#define DEFINIR_LISTA(tipo)   \
  typedef struct {            \
    tipo *itens;              \
    size_t total;             \
  } lista_ ## tipo

DEFINIR_LISTA(int);   // typedef struct { int *itens; size_t total; } lista_int;
DEFINIR_LISTA(float); // typedef struct { float *itens; size_t total; } lista_float;

lista_int numeros = {0};
```

---

**Acessando campos com prefixo**

```c
struct config {
  int opt_porta;
  int opt_timeout;
};

#define OPT(cfg, nome) ((cfg).opt_ ## nome)

struct config c = {8080, 30};
OPT(c, porta);   // c.opt_porta   -> 8080
OPT(c, timeout); // c.opt_timeout -> 30
```

---

**Juntando com o valor de outra macro**

Assim como o `#`, o `##` usa o texto do argumento antes de ele ser expandido, então juntar com uma macro cola o nome dela, e não o valor. A solução é a mesma: uma macro intermediária

```c
#define VERSAO 2

#define JUNTAR(a, b) a ## b
#define XJUNTAR(a, b) JUNTAR(a, b)

JUNTAR(api_v, VERSAO)  // api_vVERSAO
XJUNTAR(api_v, VERSAO) // api_v2
```

> Diferente do `#`, que transforma um argumento em string (`"nome"`), o `##` gera um nome de verdade que o compilador usa como identificador (`nome`). O primeiro serve para mostrar texto, o segundo para gerar código. Como o código gerado não aparece no arquivo fonte, buscar por `max_int` no projeto não encontra a definição, o que torna esse recurso algo a ser usado com moderação
