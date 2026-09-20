**strcat**

> `stdlib.h`

O `atoi` converte uma string em um número inteiro, sendo uma das formas mais simples de transformar texto em número em C

```c
#include <stdlib.h>

int atoi(const char *str);
```

- `str`: a string a ser convertida para inteiro

- Retorna o valor inteiro representado no início da string, ou `0` se nenhum número puder ser reconhecido
- Ignora espaços em branco no começo da string antes de procurar pelo número, e para de ler assim que encontra o primeiro caractere que não faça parte de um número válido (incluindo o resto da string depois dele)
- Aceita um sinal opcional (`+` ou `-`) logo antes dos dígitos
- Não tem nenhuma forma de indicar erro: uma string sem número nenhum (`"abc"`) e uma string que representa o número zero (`"0"`) retornam exatamente o mesmo valor, `0`, tornando impossível diferenciar os dois casos só pelo retorno
- Se o número representado na string for grande demais para caber em um `int`, o comportamento é indefinido; para conversões onde isso importa, `strtol` é a alternativa mais segura, por permitir checar overflow e identificar até onde a conversão avançou na string

```c
int n1 = atoi("42");        // 42
int n2 = atoi("  -17abc");  // -17
int n3 = atoi("abc");       // 0
```

