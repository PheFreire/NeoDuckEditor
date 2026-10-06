**for (;;)**

> palavra-chave da linguagem, não precisa de nenhum header

O `for (;;)` é um laço infinito: um `for` com as três partes vazias, que repete o seu corpo para sempre até que algo de dentro dele interrompa a execução, como um `break` ou um `return`

> Um `for` tem três partes separadas por `;`, todas opcionais. A `inicialização` é executada uma vez antes de começar, a `condição` é testada antes de cada volta e o `incremento` é executado no final de cada volta. Quando a condição é omitida, a linguagem a trata como sempre verdadeira

```c
for (inicialização; condição; incremento) {
  // corpo
}

for (;;) {
  // corpo repetido para sempre
}
```

- Os dois `;` são obrigatórios mesmo com as partes vazias, pois são eles que separam as três posições. `for ()` não compila
- Faz exatamente o mesmo que `while (1)`, e o compilador gera o mesmo código para os dois. A escolha é só de estilo, sendo o `for (;;)` comum em código C mais antigo e no kernel do Linux por não depender de uma constante "mágica" como o `1`
- Como não há condição de parada, o laço só termina por algo dentro dele:
	- `break`: sai do laço e continua no código logo depois dele
	- `return`: sai da função inteira
	- `exit()` ou `abort()`: encerra o programa
	- `continue`: não sai do laço, apenas pula o resto do corpo e começa a próxima volta
- Útil quando a decisão de parar só pode ser tomada no meio do corpo, depois de fazer alguma coisa, e não no começo de cada volta como em um `while` comum

Lendo linhas até o fim do arquivo, onde a parada só é conhecida depois de tentar ler:

```c
char linha[256];

for (;;) {
  if (fgets(linha, sizeof(linha), file) == NULL) {
    break; // fim do arquivo ou erro
  }

  if (linha[0] == '#') {
    continue; // ignora comentários e vai para a próxima linha
  }

  printf("%s", linha);
}
```

Um menu que repete até o usuário escolher sair:

```c
int opcao;

for (;;) {
  printf("1 - jogar\n2 - sair\n> ");
  if (scanf("%d", &opcao) != 1) {
    break; // entrada inválida ou fim do stdin
  }

  if (opcao == 2) {
    break;
  }

  jogar();
}
```

Um servidor que atende conexões para sempre, o caso clássico de um laço que nunca deveria terminar:

```c
for (;;) {
  int client_fd = accept(server_fd, NULL, NULL);
  if (client_fd < 0) {
    perror("accept");
    continue; // uma falha não deve derrubar o servidor
  }

  atender(client_fd);
  close(client_fd);
}
```

> Um `break` dentro de um `switch` que está dentro do `for (;;)` sai apenas do `switch`, e não do laço. Para sair do laço a partir de um `switch` é preciso usar um `return`, uma variável de controle ou um `goto`
