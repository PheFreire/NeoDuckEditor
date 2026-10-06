**fmod**

> `math.h`

O `fmod` calcula o resto da divisão entre dois números de ponto flutuante, sendo o equivalente do operador `%` para `double`, que só funciona com inteiros

> O resto de `x / y` é o que sobra depois de tirar de `x` a maior quantidade inteira de `y` possível: em `7.5 / 2`, cabem `3` vezes o `2` (`6`), e sobram `1.5`

```c
double fmod(double x, double y);
float fmodf(float x, float y);
long double fmodl(long double x, long double y);
```

- `x`: o dividendo
- `y`: o divisor

- Devolve `x - n * y`, onde `n` é `x / y` com a parte decimal cortada (truncada em direção ao zero)
- O resultado tem sempre o mesmo sinal de `x`, e é menor que `y` em valor absoluto
- Se `y` for `0`, devolve `NAN` (erro de domínio)

```c
double r1 = fmod(7.5, 2.0);   // 1.5
double r2 = fmod(10.0, 3.0);  // 1.0
double r3 = fmod(-7.0, 3.0);  // -1.0, mesmo sinal de x
double r4 = fmod(7.0, -3.0);  // 1.0, o sinal de y não importa

// int r = 7.5 % 2; // erro de compilação: % não aceita double
```

**Mantendo um ângulo entre 0 e 360**

Como o resultado pode ser negativo, para "dar a volta" em um intervalo é preciso corrigir o caso negativo:

```c
double normalizar_angulo(double graus) {
  double r = fmod(graus, 360.0);
  if (r < 0) {
    r += 360.0;
  }
  return r;
}

normalizar_angulo(370.0);  // 10.0
normalizar_angulo(-90.0);  // 270.0
```

**Separando horas e minutos**

```c
double total_minutos = 135.5;
double minutos = fmod(total_minutos, 60.0);     // 15.5
double horas = floor(total_minutos / 60.0);     // 2
```

**remainder**

A `math.h` também tem o `remainder`, que arredonda `x / y` para o inteiro mais próximo em vez de truncar, podendo devolver um resto negativo mesmo com `x` positivo:

```c
fmod(8.0, 3.0);      // 2.0  (8 / 3 = 2.67, truncado para 2:  8 - 6 = 2)
remainder(8.0, 3.0); // -1.0 (8 / 3 = 2.67, arredondado para 3: 8 - 9 = -1)
```

> Diferente do `%` com inteiros negativos, que em C também segue o sinal do dividendo (`-7 % 3 == -1`), o `fmod` funciona com casas decimais. Os dois se comportam igual com relação ao sinal, e nenhum deles devolve o "módulo matemático" sempre positivo sem a correção mostrada acima
