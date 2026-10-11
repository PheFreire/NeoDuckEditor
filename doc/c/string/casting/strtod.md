**strtod**

> `stdlib.h`

O `strtod` converte o começo de uma string em um número de ponto flutuante do tipo `double`, informando até onde a conversão avançou e sinalizando valores grandes demais, sendo a forma mais usada na prática para transformar texto em número com casas decimais

> Um `double` guarda números com casas decimais em 8 bytes, com cerca de 15 dígitos significativos de precisão, o dobro do `float`. Mesmo assim, valores como `0.1` não têm representação exata em binário, então o número guardado é sempre o `double` mais próximo do texto, e não exatamente o que foi escrito

```c
double strtod(const char *str, char **endptr);
```

- `str`: a string a ser convertida
- `endptr`: ponteiro para um `char *` que vai receber o endereço do primeiro caractere não convertido em `str`, logo após o número lido. Pode ser `NULL` se essa informação não for necessária

- Devolve o valor convertido como `double`. Se nenhum número puder ser reconhecido, devolve `0` e faz `endptr` apontar para o início de `str`, permitindo distinguir esse caso de uma conversão bem-sucedida de `"0"`
- Se o número for grande demais para um `double`, devolve `HUGE_VAL` (ou `-HUGE_VAL`), que equivale a infinito, e ajusta o `errno` para `ERANGE`
- Se o número for pequeno demais (muito próximo de zero), devolve um valor muito pequeno ou `0` e também pode ajustar o `errno` para `ERANGE`
- Ignora espaços em branco no início e aceita um sinal opcional (`+` ou `-`)
- Aceita vários formatos:
	- decimal: `"3.14"`, `".5"`, `"10"`
	- notação científica: `"1.5e3"` (`1500`), `"2E-2"` (`0.02`)
	- hexadecimal: `"0x1.8p1"` (`1.5 * 2¹ = 3`)
	- infinito e "não é número": `"inf"`, `"infinity"`, `"nan"`, sem diferenciar maiúsculas
- O separador decimal depende do locale do programa: no padrão (`"C"`), que é o usado se o programa não chamar `setlocale`, é sempre o `.`

```c
char *fim;

double d1 = strtod("3.14", &fim);       // 3.14, fim aponta para '\0'
double d2 = strtod("  -2.5kg", &fim);   // -2.5, fim aponta para "kg"
double d3 = strtod("1e3", &fim);        // 1000
double d4 = strtod("abc", &fim);        // 0, fim aponta para o início de "abc"
double d5 = strtod("1e400", &fim);      // inf, errno == ERANGE
```

Validando que a string é só um número, sem nada depois e sem estourar:

```c
#include <errno.h>
#include <stdlib.h>

const char *entrada = "9.81";
char *fim;

errno = 0;
double gravidade = strtod(entrada, &fim);

if (fim == entrada || *fim != '\0' || errno == ERANGE) {
  // não era um número válido, ou não cabe em um double
}
```

Como `"inf"` e `"nan"` também são aceitos, quando só números comuns devem passar é preciso checar o resultado com o `isfinite` (`math.h`):

```c
#include <math.h>

double v = strtod("nan", &fim); // conversão válida, fim aponta para '\0'
if (!isfinite(v)) {
  // era "inf", "infinity" ou "nan"
}
```

A precisão do `double` também é limitada, só que mais casas depois:

```c
double d = strtod("0.1", NULL);
printf("%.20f\n", d); // 0.10000000000000000555
```

---

**Família strtod**

- `strtof`: devolve `float` (C99)
- `strtod`: devolve `double`, o mais usado na prática
- `strtold`: devolve `long double`, com ainda mais precisão dependendo da plataforma

Todas têm os mesmos parâmetros e o mesmo comportamento, mudando apenas o tipo devolvido

> O `atof` também devolve um `double`, mas não indica até onde leu e não tem nenhuma forma de sinalizar erro, então `"abc"` e `"0"` devolvem o mesmo `0`. O `strtod` resolve isso pelo `endptr` e pelo `errno`, sendo a forma recomendada de converter números decimais vindos do usuário ou de arquivos. Diferente do `strtol`, ele não recebe uma `base`, pois detecta sozinho se o número está em decimal ou hexadecimal pelo prefixo `0x`
