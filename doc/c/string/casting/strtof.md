**strtof**

> `stdlib.h`

O `strtof` converte o começo de uma string em um número de ponto flutuante do tipo `float`, informando até onde a conversão avançou e sinalizando valores grandes demais, sendo o equivalente do `strtol` para números com casas decimais

> Um `float` guarda números com casas decimais em 4 bytes, com cerca de 7 dígitos significativos de precisão. Muitos valores decimais, como `0.1`, não têm representação exata em binário, então o número guardado é sempre o `float` mais próximo do texto, e não exatamente o que foi escrito

```c
float strtof(const char *str, char **endptr);
```

- `str`: a string a ser convertida
- `endptr`: ponteiro para um `char *` que vai receber o endereço do primeiro caractere não convertido em `str`, logo após o número lido. Pode ser `NULL` se essa informação não for necessária

- Devolve o valor convertido como `float`. Se nenhum número puder ser reconhecido, devolve `0` e faz `endptr` apontar para o início de `str`, permitindo distinguir esse caso de uma conversão bem-sucedida de `"0"`
- Se o número for grande demais para um `float`, devolve `HUGE_VALF` (ou `-HUGE_VALF`), que equivale a infinito, e ajusta o `errno` para `ERANGE`
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

float f1 = strtof("3.14", &fim);       // 3.14, fim aponta para '\0'
float f2 = strtof("  -2.5kg", &fim);   // -2.5, fim aponta para "kg"
float f3 = strtof("1e3", &fim);        // 1000
float f4 = strtof("abc", &fim);        // 0, fim aponta para o início de "abc"
float f5 = strtof("1e50", &fim);       // inf, errno == ERANGE
```

Validando que a string é só um número, sem nada depois e sem estourar:

```c
#include <errno.h>
#include <stdlib.h>

const char *entrada = "9.81";
char *fim;

errno = 0;
float gravidade = strtof(entrada, &fim);

if (fim == entrada || *fim != '\0' || errno == ERANGE) {
  // não era um número válido, ou não cabe em um float
}
```

A precisão limitada do `float` aparece ao imprimir com mais casas:

```c
float f = strtof("0.1", NULL);
printf("%.10f\n", f); // 0.1000000015
```

**Família strtof**

- `strtof`: devolve `float` (C99)
- `strtod`: devolve `double`, com cerca de 15 dígitos de precisão, o mais usado na prática
- `strtold`: devolve `long double`, com ainda mais precisão dependendo da plataforma

Todas têm os mesmos parâmetros e o mesmo comportamento, mudando apenas o tipo devolvido

> Diferente do `atof`, que devolve um `double`, não indica até onde leu e não tem nenhuma forma de sinalizar erro, o `strtof` permite saber se havia de fato um número na string e se ele cabia no tipo. Além disso, diferente do `strtol`, ele não recebe uma `base`, pois detecta sozinho se o número está em decimal ou hexadecimal pelo prefixo `0x`
