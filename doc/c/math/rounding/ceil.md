**ceil**

> `math.h`

O `ceil` (de "ceiling", teto) arredonda um número para cima, devolvendo o menor número inteiro que seja maior ou igual a ele

> Arredondar "para cima" significa ir na direção do `+infinito`, e não "para longe do zero": `ceil(2.1)` é `3`, mas `ceil(-2.9)` é `-2`, já que `-2` é maior que `-2.9`

```c
double ceil(double x);
float ceilf(float x);
long double ceill(long double x);
```

- `x`: o número a ser arredondado

- Devolve o resultado como `double`, e não como `int`, mesmo que o valor seja inteiro
- Um número que já é inteiro não muda: `ceil(4.0)` é `4.0`

```c
ceil(2.1);   // 3.0
ceil(2.9);   // 3.0
ceil(2.0);   // 2.0
ceil(-2.1);  // -2.0
ceil(-2.9);  // -2.0
```

O uso mais comum é calcular quantos "grupos" são necessários para caber uma quantidade, quando um grupo parcial também conta:

```c
int itens = 23;
int por_pagina = 10;

int paginas = (int)ceil((double)itens / por_pagina); // 3, e não 2
```

> O cast para `double` é obrigatório: `itens / por_pagina` com dois `int` já dá `2` (divisão inteira), e `ceil(2)` continua `2`. Com inteiros positivos, o mesmo resultado pode ser obtido sem a `math.h`, com `(itens + por_pagina - 1) / por_pagina`

> Diferente do `floor`, que vai sempre para baixo, e do `round`, que vai para o inteiro mais próximo, o `ceil` vai sempre para cima, mesmo que a parte decimal seja mínima (`ceil(2.0001)` é `3`)
