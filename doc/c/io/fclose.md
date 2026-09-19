**fclose**

O `fclose` fecha um `stream` aberto com `fopen`, garantindo que todo dado ainda pendente no buffer interno da `stdio.h` seja de fato escrito no arquivo antes de encerrar

```c
int fclose(FILE *stream);
```

- `stream`: o ponteiro do arquivo a ser fechado

- Devolve `0` em caso de sucesso, ou `EOF` se ocorrer algum erro ao fechar
- Depois de fechado, o ponteiro `stream` fica dangling, assim como acontece com um ponteiro depois de um `free`

```c
FILE *file = fopen("dados.txt", "w");
fprintf(file, "ola mundo");
fclose(file); // só aqui o conteúdo é garantidamente gravado no arquivo
```

> As funções de escrita como `fprintf` costumam guardar os dados em um buffer interno antes de gravar no disco, por questão de performance. Se o programa terminar sem chamar `fclose` (por exemplo, travando ou sendo encerrado à força), esse buffer pode nunca ser escrito, perdendo os dados que ainda não tinham sido gravados

