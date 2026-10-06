**fsetpos**

> `stdio.h`

O `fsetpos` move o cursor do stream de volta para uma posição salva anteriormente com `fgetpos`, permitindo retomar a leitura ou escrita exatamente daquele ponto

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int fsetpos(FILE *stream, const fpos_t *pos);
```

- `stream`: o stream cujo cursor será movido
- `pos`: ponteiro para a variável `fpos_t` com a posição salva antes pelo `fgetpos`

- Devolve `0` em caso de sucesso, ou um valor diferente de `0` se ocorrer algum erro, deixando o motivo em `errno`
- O `pos` precisa ter vindo de um `fgetpos` feito no mesmo stream. Usar um `fpos_t` de outro stream, ou um valor montado à mão, é comportamento indefinido
- Assim como o `fseek`, limpa o indicador de fim de arquivo (`EOF`) do stream, então é possível voltar a ler normalmente mesmo depois de ter chegado ao final
- Em streams abertos para leitura e escrita (`"r+"`, `"w+"`, `"a+"`), é preciso chamar `fsetpos`, `fseek`, `rewind` ou `fflush` entre uma escrita e uma leitura seguinte. O `fsetpos` serve para fazer essa troca

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
if (fsetpos(file, &pos) != 0) {
  perror("fsetpos");
  return 1;
}
```

> O `fsetpos` só sabe voltar para pontos marcados com `fgetpos`. Para pular para uma posição calculada (como o início, o fim ou um deslocamento em bytes), use `fseek` ou `rewind`
