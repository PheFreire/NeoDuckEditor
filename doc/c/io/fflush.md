**fflush**

> `stdio.h`

O `fflush` força a escrita imediata de todo dado que ainda está pendente no buffer interno de um stream de saída, sem precisar fechá-lo com `fclose`

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
int fflush(FILE *stream);
```

- `stream`: o stream de saída cujo buffer deve ser esvaziado. Se for `NULL`, o `fflush` esvazia o buffer de todos os streams de saída abertos

- Devolve `0` em caso de sucesso, ou `EOF` se ocorrer algum erro ao escrever, deixando o motivo em `errno`
- Diferente do `fclose`, o stream continua aberto e pode seguir sendo usado normalmente depois do `fflush`
- O `stdout` ligado a um terminal costuma ter buffer por linha, ou seja, só é escrito quando aparece um `\n`. Por isso um `printf` sem quebra de linha pode não aparecer na tela até que o `fflush(stdout)` seja chamado
- O `stderr` não tem buffer, então tudo que é escrito nele já aparece imediatamente, sem precisar de `fflush`
- Chamar `fflush(stdin)` é comportamento indefinido pelo padrão C. O `fflush` só deve ser usado em streams de saída (ou em streams de atualização cuja última operação tenha sido uma escrita)

```c
printf("Digite seu nome: ");
fflush(stdout); // garante que o texto aparece antes do programa esperar a entrada
scanf("%49s", nome);
```

Garantindo que um log seja gravado no arquivo a cada escrita, mesmo que o programa trave depois:

```c
FILE *log = fopen("app.log", "a");
fprintf(log, "iniciando processamento\n");
fflush(log); // o conteúdo já está no arquivo, mesmo sem o fclose
```

> O `fflush` apenas transfere os dados do buffer da `stdio.h` para o sistema operacional. O sistema ainda pode mantê-los em cache na memória antes de gravar fisicamente no disco. Para garantir a gravação no disco é preciso usar também o `fsync`, de `unistd.h`, passando o descritor do arquivo obtido com `fileno(file)`
