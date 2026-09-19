**fopen**

> `stdio.h`

O `fopen` abre um arquivo e devolve um ponteiro `FILE *`, o stream que as demais funções (`fgets`, `fread`, etc.) vão usar para ler ou escrever nesse arquivo

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
FILE *fopen(const char *filename, const char *mode);
```

- `filename`: o caminho do arquivo a ser aberto
- `mode`: como o arquivo vai ser aberto, por exemplo `"r"` para leitura, `"w"` para escrita (cria o arquivo se ele não existir, apaga o conteúdo se já existir) ou `"a"` para adicionar ao final, podendo ser combinado com `"b"` para tratar o arquivo como binário (ex: `"rb"`)
- Devolve `NULL` quando o arquivo não pode ser aberto, por exemplo se ele não existe e o modo pedido é de leitura

```c
FILE *file = fopen("dados.txt", "r");
if (file == NULL) {
  // não foi possível abrir o arquivo
}
```

> Assim como toda alocação com `malloc` precisa de um `free`, todo `fopen` precisa ser fechado com `fclose(file)` quando o arquivo não for mais usado, devolvendo ao sistema os recursos associados a ele
