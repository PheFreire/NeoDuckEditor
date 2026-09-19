**fread**

> `stdio.h`

O `fread` lê dados binários de um `stream` e copia para dentro do buffer que você já possui, sem se importar com quebras de linha ou `\0`, lendo exatamente a quantidade de bytes pedida.

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
size_t fread(void *buffer, size_t size, size_t count, FILE *stream);
```

- `buffer`: o buffer que você já possui, para onde os dados lidos vão ser copiados
- `size`: o tamanho em bytes de cada item a ser lido
- `count`: quantos itens de `size` bytes devem ser lidos
- `stream`: de onde os bytes serão lidos

- Devolve a quantidade de itens efetivamente lidos, que pode ser menor que `count` se o arquivo acabar antes ou ocorrer algum erro
- Ideal para ler arquivos binários, structs ou blocos grandes de dados, pois lê exatamente a quantidade de bytes pedida, sem parar em quebras de linha como o `fgets`

```c
int valores[10];
size_t lidos = fread(valores, sizeof(int), 10, file);
// lidos guarda quantos inteiros foram realmente lidos
```

