**fseek**

> `stdio.h`

O `fseek` move o cursor do stream para uma posição específica, permitindo pular partes do arquivo sem precisar ler byte a byte até chegar lá

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int fseek(FILE *stream, long offset, int whence);
```

- `stream`: o ponteiro do arquivo
- `offset`: quantos bytes mover o cursor a partir do ponto de referência definido em `whence` (positivo para frente, negativo para trás)
- `whence`: o ponto de referência de onde `offset` é contado
	- `SEEK_SET`: o início do arquivo
	- `SEEK_CUR`: a posição atual do cursor
	- `SEEK_END`: o final do arquivo

```c
fseek(file, 0, SEEK_END); // move o cursor para o final do arquivo
```

