**fprintf**

> `stdio.h`

O `fprintf` funciona como um `printf` que, em vez de escrever sempre no terminal (`stdout`), escreve a saída formatada em qualquer `stream`, como um arquivo aberto com `fopen`

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int fprintf(FILE *stream, const char *format, ...);
```

- `stream`: para onde o texto formatado será escrito
- `format`: a string de formato, com os mesmos especificadores usados no `printf` (`%d`, `%s`, `%f`, etc)
- `...`: os valores a serem inseridos no lugar de cada especificador em `format`

- Devolve a quantidade de caracteres escritos, ou um valor negativo se ocorrer algum erro

```c
FILE *file = fopen("log.txt", "a");
fprintf(file, "usuario %s logou as %d:%d\n", nome, hora, minuto);
fclose(file);
```

> Assim como o `fgets` é a forma de ler uma linha inteira para dentro de um buffer, o `fprintf` é a forma mais comum de escrever dados formatados em um arquivo, só que na direção oposta: aqui é o programa que gera o texto, não o arquivo que fornece

> `printf(...)` é, na prática, equivalente a `fprintf(stdout, ...)`

