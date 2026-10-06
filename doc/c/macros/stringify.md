**Operador #**

> diretiva do pré-processador, não precisa de nenhum header

O operador `#`, usado dentro de uma macro com parâmetros, transforma o argumento passado em uma string literal, exatamente como ele foi escrito no código, permitindo imprimir o nome de uma variável ou o texto de uma expressão

> Esse processo é chamado de `stringify` (ou stringização). O pré-processador não calcula nada: ele pega o texto do argumento, coloca entre aspas e escapa os `"` e `\` que houver dentro dele

```c
#define NOME(param) #param
```

- `#param`: vira `"texto do argumento"`
- Só funciona dentro de macros com parâmetros, e o `#` precisa vir antes do nome de um parâmetro
- Espaços no começo e no fim do argumento são removidos, e espaços repetidos no meio viram um só

```c
#define STR(x) #x

STR(ola)        // "ola"
STR(1 + 2)      // "1 + 2"
STR(a  ==   b)  // "a == b"
STR("aspas")    // "\"aspas\""
```

---

**Imprimindo nome e valor de uma variável**

Como duas strings literais lado a lado são juntadas pelo compilador (`"a" "b"` vira `"ab"`), o resultado do `#` pode ser combinado com outros textos:

```c
#define PRINT_INT(var) printf(#var " = %d\n", var)

int idade = 25;
PRINT_INT(idade);
// vira:  printf("idade" " = %d\n", idade);
// saída: idade = 25

PRINT_INT(idade * 2);
// saída: idade * 2 = 50
```

---

**Mostrando a condição que falhou**

É assim que o `assert` consegue imprimir a expressão que deu errado:

```c
#define CHECAR(cond)                                  \
  do {                                                \
    if (!(cond)) {                                    \
      fprintf(stderr, "falhou: %s\n", #cond);         \
    }                                                 \
  } while (0)

CHECAR(x > 0);
// se x for 0, saída: falhou: x > 0
```

---

**Transformando o valor de outra macro em string**

O `#` aplica-se ao texto do argumento antes de ele ser expandido, então passar uma macro gera o nome dela, e não o valor:

```c
#define VERSAO 3
#define STR(x) #x

STR(VERSAO) // "VERSAO", e não "3"
```

Para obter o valor, usa-se uma macro intermediária: o argumento é expandido ao passar pela primeira, e só depois chega ao `#` da segunda:

```c
#define STR(x) #x
#define XSTR(x) STR(x)

XSTR(VERSAO) // XSTR(VERSAO) -> STR(3) -> "3"
XSTR(__LINE__) // "42", o número da linha como string
```

> Diferente de uma função, que só recebe o valor já calculado de um argumento, uma macro tem acesso ao texto original dele, e o `#` é a forma de aproveitar isso. É por isso que ferramentas de log, testes e o próprio `assert` são escritos como macros e não como funções
