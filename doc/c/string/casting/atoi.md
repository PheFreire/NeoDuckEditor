**atoi**

> `stdlib.h`

O `atoi` converte uma string em um número inteiro, sendo uma das formas mais simples de transformar texto em número em C

```c
int atoi(const char *str);
```

- `str`: a string a ser convertida para inteiro

- Devolve o valor inteiro representado no início da string, ou `0` se nenhum número puder ser reconhecido
- Ignora espaços em branco no começo da string, e para de ler assim que encontra o primeiro caractere que não faça parte de um número válido, descartando o resto da string
- Aceita um sinal opcional (`+` ou `-`) logo antes dos dígitos
- Não tem nenhuma forma de indicar erro: uma string sem número nenhum (`"abc"`) e a string `"0"` devolvem exatamente o mesmo valor, `0`, tornando impossível diferenciar os dois casos só pelo retorno
- Se o número for grande demais para caber em um `int`, o comportamento é indefinido

```c
int n1 = atoi("42");        // 42
int n2 = atoi("  -17abc");  // -17
int n3 = atoi("abc");       // 0
```

> Quando é preciso detectar erro ou overflow, o `strtol` é a alternativa mais segura, por permitir checar até onde a conversão avançou na string e sinalizar valores fora do limite
