**strtok**

> `string.h`

O `strtok` funciona como um split, separando uma string em pedaços (tokens) a partir de um conjunto de delimitadores. Diferente de um split de outras linguagens, ele não cria uma cópia nem um array novo: ele modifica o próprio buffer, escrevendo um `\0` em cima de cada delimitador encontrado, e devolve um ponteiro para o início de cada pedaço já terminado nesse `\0`

```c
char *strtok(char *str, const char *delim);
```

- Na primeira chamada passa-se a string que será cortada. Nas chamadas seguintes passa-se `NULL`, e o `strtok` continua de onde parou, guardando a posição atual em uma variável interna própria da função
- Cada chamada devolve um ponteiro para o início do próximo token
- Quando não sobra mais nenhum token, `strtok` devolve `NULL`
- Quando dois ou mais delimitadores aparecem em sequência, `strtok` pula todos eles de uma vez até achar o próximo caractere que não seja delimitador, por isso nunca devolve um token vazio entre eles: em `"a,,b"` cortado por `","`, os tokens são `"a"` e `"b"`, nunca `"a"`, `""` e `"b"`

> Por guardar a posição em uma variável interna compartilhada, `strtok` não deve ser usado para cortar duas strings ao mesmo tempo, como em chamadas aninhadas, pois uma chamada apaga o progresso da outra

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

Juntando as chamadas em um laço até `strtok` devolver `NULL`:

```c
char str[] = "Programar em C e muito legal";
char delimitadores[] = " ";

char *token = strtok(str, delimitadores);

while (token != NULL) {
  printf("%s\n", token);
  token = strtok(NULL, delimitadores);
}

// Saída:
// Programar
// em
// C
// e
// muito
// legal
```

