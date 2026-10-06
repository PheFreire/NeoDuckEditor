**fgetpos**

> `stdio.h`

O `fgetpos` salva a posição atual do cursor do stream em uma variável do tipo `fpos_t`, para que depois seja possível voltar exatamente para esse ponto com `fsetpos`

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int fgetpos(FILE *stream, fpos_t *pos);
```

- `stream`: o stream cuja posição será lida
- `pos`: ponteiro para a variável `fpos_t` onde a posição atual será guardada

- Devolve `0` em caso de sucesso, ou um valor diferente de `0` se ocorrer algum erro, deixando o motivo em `errno`
- O `fpos_t` é um tipo opaco: seu conteúdo não deve ser lido nem calculado, ele serve apenas para ser passado de volta ao `fsetpos` no mesmo stream
- Diferente do `ftell`, que devolve um `long` e pode estourar em arquivos muito grandes, o `fpos_t` consegue representar qualquer posição do arquivo, incluindo o estado de leitura de caracteres multibyte

```c
fpos_t pos;
fgetpos(file, &pos);  // salva a posição atual

char linha[256];
fgets(linha, sizeof(linha), file); // lê uma linha, avançando o cursor

fsetpos(file, &pos);  // volta para a posição salva
fgets(linha, sizeof(linha), file); // lê a mesma linha de novo
```

Checando erro na chamada:

```c
fpos_t pos;
if (fgetpos(file, &pos) != 0) {
  perror("fgetpos");
  return 1;
}
```

> Quando é preciso saber a posição como número (por exemplo, para calcular o tamanho do arquivo ou pular uma quantidade de bytes), use `ftell` e `fseek`. O par `fgetpos`/`fsetpos` serve apenas para marcar um ponto e voltar a ele depois
