**pow**

> `math.h`

O `pow` (de "power", potência) eleva um número a outro, calculando `xʸ`, e aceita expoentes negativos e com casas decimais, já que em C não existe um operador de potência

> Em C, o `^` não é potência, é o operador "ou exclusivo" (XOR) bit a bit: `2 ^ 3` vale `1`, e não `8`. Para potência é sempre preciso usar o `pow`

```c
double pow(double x, double y);
float powf(float x, float y);
long double powl(long double x, long double y);
```

- `x`: a base
- `y`: o expoente

- Devolve `x` elevado a `y`
- Um expoente negativo é o inverso: `pow(2, -1)` é `1 / 2 = 0.5`
- Um expoente fracionário é uma raiz: `pow(x, 0.5)` é a raiz quadrada de `x`
- `pow(x, 0)` é `1` para qualquer `x`, inclusive `pow(0, 0)`

```c
pow(2, 10);    // 1024.0
pow(2, -2);    // 0.25
pow(9, 0.5);   // 3.0
pow(-2, 3);    // -8.0, base negativa com expoente inteiro funciona
pow(10, 3);    // 1000.0

int errado = 2 ^ 3; // 1, XOR, não potência
```

---

**Erros**

- Base negativa com expoente fracionário não tem resultado real e devolve `NAN`: `pow(-8, 1.0 / 3)` é `NAN`, e não `-2` (para isso existe o `cbrt`)
- `pow(0, negativo)` é uma divisão por zero e devolve `INFINITY`
- Um resultado grande demais devolve `HUGE_VAL`: `pow(10, 400)` é `inf`

---

**Potências inteiras**

O `pow` sempre trabalha com `double`, então o resultado precisa ser convertido para usar como inteiro, e números grandes podem perder precisão:

```c
int n = (int)pow(2, 10); // 1024

long long grande = (long long)pow(3, 39);
// 3^39 = 4052555153018976267, mas um double só tem ~15 dígitos exatos,
// então o valor convertido pode errar nos últimos dígitos
```

Para potências inteiras, um laço com multiplicação é exato e não precisa da `math.h`:

```c
long long potencia(long long base, unsigned int exp) {
  long long resultado = 1;
  for (unsigned int i = 0; i < exp; i++) {
    resultado *= base;
  }
  return resultado;
}
```

Para quadrados e cubos, multiplicar direto (`x * x`) é mais simples e mais rápido que chamar `pow(x, 2)`

> Diferente do `sqrt` e do `cbrt`, que são especializados em raízes e mais precisos, o `pow` é genérico e mais lento. Use as funções específicas quando elas existirem, e o `pow` para expoentes que não são conhecidos de antemão ou que têm casas decimais
