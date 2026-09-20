**scanf**

> `stdio.h`

O `scanf` lê a entrada padrão (`stdin`) e interpreta o que foi digitado de acordo com um formato, guardando os valores extraídos direto nas variáveis passadas por ponteiro

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int scanf(const char *format, ...);
```

- `format`: a string de formato, indicando como interpretar a entrada (`%d`, `%s`, `%f`, etc)
- `...`: ponteiros para as variáveis onde cada valor lido será guardado

- Devolve a quantidade de valores lidos e atribuídos com sucesso, permitindo checar se a entrada tinha o formato esperado
- `scanf(...)` é, na prática, equivalente a `fscanf(stdin, ...)`, a versão de `scanf` que lê de um `stream` qualquer

```c
int idade;
scanf("%d", &idade);
```

> Diferente do `fgets`, o `%s` do `scanf` não tem como saber o tamanho do buffer de destino, então não protege sozinho contra buffer overflow; por isso, para ler texto do usuário com segurança, é comum usar `fgets` para pegar a linha inteira e depois `sscanf` para extrair os valores dela

**sscanf**

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

