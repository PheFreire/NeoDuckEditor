**Armadilhas de expansão**

> diretiva do pré-processador, não precisa de nenhum header

Como o pré-processador apenas copia e cola o texto dos argumentos dentro da macro, sem calcular nada antes, uma macro escrita sem cuidado pode gerar uma expressão com precedência diferente da esperada ou executar o mesmo argumento várias vezes

> O compilador só vê o código já expandido. Em uma função, `f(1 + 2)` recebe o valor `3`. Em uma macro, `M(1 + 2)` recebe o texto `1 + 2`, que é colado como está em cada lugar onde o parâmetro aparece

- Todo parâmetro deve ser envolvido em parênteses dentro do texto da macro: `(x)`
- O texto inteiro da macro também deve ser envolvido em parênteses: `((x) * (x))`
- Um argumento com efeito colateral (`i++`, chamada de função) não deve ser passado para uma macro que usa o parâmetro mais de uma vez

---

**Problema 1: faltam parênteses nos parâmetros**

```c
#define QUADRADO(x) x * x

int r = QUADRADO(1 + 2);
// esperado: 3 * 3 = 9
// vira:     1 + 2 * 1 + 2
// como * vem antes de +: 1 + 2 + 2 = 5
```

Envolvendo cada parâmetro em parênteses, o argumento é calculado antes da multiplicação:

```c
#define QUADRADO(x) (x) * (x)

int r = QUADRADO(1 + 2);
// vira: (1 + 2) * (1 + 2) = 9
```

---

**Problema 2: faltam parênteses na macro inteira**

Mesmo com os parâmetros protegidos, o resultado da macro ainda pode ser "quebrado" pelo operador ao redor dela:

```c
#define DOBRO(x) (x) + (x)

int r = 10 * DOBRO(3);
// esperado: 10 * 6 = 60
// vira:     10 * (3) + (3)
// que é:    30 + 3 = 33
```

Envolvendo o texto inteiro, a macro se comporta como um valor único:

```c
#define DOBRO(x) ((x) + (x))

int r = 10 * DOBRO(3);
// vira: 10 * ((3) + (3)) = 60
```

---

**Problema 3: argumento avaliado mais de uma vez**

Os parênteses não resolvem este caso: se o parâmetro aparece duas vezes no texto, o argumento é executado duas vezes

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))

int i = 5;
int j = 3;
int m = MAX(i++, j);
// vira: ((i++) > (j) ? (i++) : (j))
// i++ roda na comparação (5 > 3, i vira 6) e de novo no resultado (m = 6, i vira 7)
// esperado: m = 5, i = 6
// obtido:   m = 6, i = 7
```

O mesmo acontece com chamadas de função, que ficam mais lentas ou repetem efeitos colaterais:

```c
int m = MAX(calcular(), 10);
// calcular() pode ser chamada duas vezes
```

A solução é calcular o valor antes e passar só a variável, ou usar uma função no lugar da macro:

```c
int a = i++;
int m = MAX(a, j); // seguro

static inline int max_int(int a, int b) {
  return a > b ? a : b; // cada argumento é avaliado uma única vez
}
```

> Diferente de uma função, que avalia cada argumento exatamente uma vez antes de ser chamada, uma macro repete o texto do argumento a cada uso do parâmetro. Por isso a regra é: parênteses em todo parâmetro, parênteses na macro inteira, e nunca passar `++`, `--` ou chamadas com efeito colateral para uma macro
