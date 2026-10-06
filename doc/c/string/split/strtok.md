**strtok**

> `string.h`

O `strtok` funciona como um split, separando uma string em pedaços (tokens) a partir de um conjunto de delimitadores. Diferente de um split de outras linguagens, ele não cria uma cópia nem um array novo: ele modifica o próprio buffer, escrevendo um `\0` em cima de cada delimitador encontrado, e devolve um ponteiro para o início de cada pedaço já terminado nesse `\0`

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
char *strtok(char *str, const char *delim);
```

- `str`: a string que será cortada na primeira chamada, ou `NULL` nas chamadas seguintes para continuar de onde parou
- `delim`: o conjunto de caracteres usados como delimitadores, onde cada caractere é tratado individualmente (`" ,"` corta tanto em espaço quanto em vírgula)

- Devolve um ponteiro para o início do próximo token, ou `NULL` quando não sobra mais nenhum
- Guarda a posição atual em uma variável interna própria da função, por isso nas chamadas seguintes basta passar `NULL`
- Quando dois ou mais delimitadores aparecem em sequência, pula todos eles de uma vez, por isso nunca devolve um token vazio: em `"a,,b"` cortado por `","`, os tokens são `"a"` e `"b"`, nunca `"a"`, `""` e `"b"`
- Como escreve no buffer, a string passada não pode ser um literal (`char *s = "a b"`), apenas um array modificável (`char s[] = "a b"`) ou memória alocada

Para entender o que acontece com o buffer original, veja como ele muda a cada chamada:

```c
char str[] = "Programar em C e muito legal";
// buffer antes de qualquer chamada:
// "Programar em C e muito legal\0"

char *token = strtok(str, " ");
// strtok troca o primeiro espaço por '\0' e devolve o pedaço antes dele
// buffer agora: "Programar\0em C e muito legal\0"
// token aponta para "Programar"

token = strtok(NULL, " ");
// como passamos NULL, ele continua da posição salva internamente
// buffer agora: "Programar\0em\0C e muito legal\0"
// token aponta para "em"
```

Juntando as chamadas em um laço para preencher um ponteiro de ponteiros (`char **`) dinamicamente:

```c
char **serialize(char *data, int *out_count) {
  int capacity = 4;
  int count = 0;

  // aloca um array para guardar os endereços (ponteiros) de cada palavra
  char **items = malloc(capacity * sizeof(char *));

  char *token = strtok(data, " ");
  while (token != NULL) {
    if (count >= capacity) {
      capacity *= 2;
      items = realloc(items, capacity * sizeof(char *));
    }

    // guarda o endereço de onde o token começa dentro do buffer original
    items[count] = token;
    count++;

    token = strtok(NULL, " ");
  }

  *out_count = count;
  return items;
}
```

> Por guardar a posição em uma variável interna compartilhada, o `strtok` não deve ser usado para cortar duas strings ao mesmo tempo, como em chamadas aninhadas, pois uma chamada apaga o progresso da outra. Além disso, os ponteiros devolvidos apontam para dentro do buffer original, então eles deixam de ser válidos se esse buffer for liberado ou sair de escopo
