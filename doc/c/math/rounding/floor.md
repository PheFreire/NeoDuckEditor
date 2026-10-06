**floor**

> `math.h`

O `floor` (chão) arredonda um número para baixo, devolvendo o maior número inteiro que seja menor ou igual a ele

> Arredondar "para baixo" significa ir na direção do `-infinito`, e não "em direção ao zero": `floor(2.9)` é `2`, mas `floor(-2.1)` é `-3`, já que `-3` é menor que `-2.1`

```c
double floor(double x);
float floorf(float x);
long double floorl(long double x);
```

- `x`: o número a ser arredondado

- Devolve o resultado como `double`, e não como `int`
- Um número que já é inteiro não muda: `floor(4.0)` é `4.0`

```c
floor(2.1);   // 2.0
floor(2.9);   // 2.0
floor(-2.1);  // -3.0
floor(-2.9);  // -3.0
```

**floor x cast para int**

Converter um `double` para `int` com um cast também remove a parte decimal, mas em direção ao zero, o que só dá o mesmo resultado para números positivos:

```c
(int)2.7;          // 2
(int)floor(2.7);   // 2

(int)-2.7;         // -2, cortou em direção ao zero
(int)floor(-2.7);  // -3, foi para baixo
```

**Convertendo uma coordenada em índice de grade**

Em jogos e gráficos, para descobrir em qual célula de uma grade um ponto está, o `floor` funciona também com coordenadas negativas, onde o cast daria a célula errada:

```c
double tamanho_celula = 32.0;
double x = -10.0;

int coluna_certa = (int)floor(x / tamanho_celula); // -1
int coluna_errada = (int)(x / tamanho_celula);     // 0, mesma célula de x = 10
```

**Separando parte inteira e decimal**

```c
double valor = 7.85;
double inteira = floor(valor);     // 7.0
double decimal = valor - inteira;  // 0.85 (aproximadamente)
```

> Diferente do `trunc` e do cast para `int`, que cortam em direção ao zero, o `floor` vai sempre para o inteiro de baixo. Para números positivos os três dão o mesmo resultado, e a diferença só aparece com negativos
