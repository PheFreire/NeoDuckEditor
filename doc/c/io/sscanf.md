**sscanf**

> `stdio.h`

O `sscanf` funciona como um `scanf` que, em vez de ler a entrada do teclado (`stdin`), lê e interpreta o conteúdo de uma string que você já possui em memória, extraindo valores dela de acordo com um formato

```c
int sscanf(const char *str, const char *format, ...);
```

- `str`: a string já existente em memória de onde os valores serão extraídos
- `format`: a string de formato, indicando como interpretar o conteúdo de `str` (`%d`, `%s`, `%f`, etc)
- `...`: ponteiros para as variáveis onde cada valor extraído será guardado

- Devolve a quantidade de valores que foram lidos e atribuídos com sucesso, o que permite checar se a string tinha o formato esperado
- Muito usado junto com o `fgets`: primeiro lê-se uma linha inteira para um buffer com `fgets`, depois extraem-se os valores dela com `sscanf`, evitando os problemas do `scanf` direto no `stdin`

```c
char linha[] = "pato 25";
char nome[20];
int idade;

sscanf(linha, "%s %d", nome, &idade);
// nome = "pato", idade = 25
```

> Diferente do `strtok`, o `sscanf` não modifica a string original nem depende de delimitadores fixos, ele apenas interpreta o conteúdo de acordo com o formato pedido

