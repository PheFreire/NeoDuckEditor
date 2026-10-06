**round**

> `math.h`

O `round` arredonda um número para o inteiro mais próximo, e quando ele está exatamente no meio entre dois inteiros (parte decimal `.5`), arredonda para longe do zero

> Existem várias regras para o caso `.5`. O `round` usa a que se aprende na escola ("meio arredonda para cima" em valor absoluto): `2.5` vira `3` e `-2.5` vira `-3`. Outras funções, como o `rint`, usam o "arredondamento do banqueiro", que vai para o par mais próximo

```c
double round(double x);
float roundf(float x);
long double roundl(long double x);

long lround(double x);
long long llround(double x);
```

- `x`: o número a ser arredondado

- `round` devolve o resultado como `double`
- `lround` e `llround` já devolvem um `long` / `long long`, evitando o cast. Se o valor não couber no tipo, o resultado é indefinido

```c
round(2.4);   // 2.0
round(2.5);   // 3.0
round(2.6);   // 3.0
round(-2.5);  // -3.0, para longe do zero
round(-2.4);  // -2.0

long n = lround(7.5); // 8
```

**Arredondando para casas decimais**

O `round` só arredonda para inteiros. Para manter `n` casas, multiplica-se por `10ⁿ`, arredonda-se e divide-se de volta:

```c
double preco = 19.987;
double arredondado = round(preco * 100.0) / 100.0; // 19.99
```

> O resultado continua sendo uma aproximação em binário: `19.99` não tem representação exata, então ele é guardado como `19.989999999999998...`. Para exibir, o `printf("%.2f", preco)` já arredonda sozinho. Para dinheiro, o recomendado é guardar os valores em centavos, como inteiros

**rint e nearbyint**

Arredondam de acordo com o modo de arredondamento atual do processador, que por padrão é o "do banqueiro": no caso `.5`, vai para o inteiro par mais próximo, o que evita que muitos arredondamentos seguidos puxem a soma sempre para cima

```c
rint(2.5);  // 2.0, 2 é par
rint(3.5);  // 4.0, 4 é par
round(2.5); // 3.0
```

> Diferente do cast para `int`, que simplesmente corta a parte decimal (`(int)2.9` é `2`), o `round` vai para o inteiro mais próximo. A forma antiga `(int)(x + 0.5)` só funciona para positivos e erra para negativos (`(int)(-2.7 + 0.5)` dá `-2`, e não `-3`), por isso o `round` / `lround` é sempre preferível
