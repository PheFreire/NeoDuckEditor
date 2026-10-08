**snprintf**

> `stdio.h`

O `snprintf` escreve texto formatado dentro de uma string, funcionando como um `printf` cujo destino é um buffer em vez da tela, sendo a forma mais comum de converter números (e outros valores) em string

Seu resultado é bem proximo de uma formatação de string `format` do python

```c
int snprintf(char *str, size_t size, const char *format, ...);
```

- `str`: o buffer que você já possui, para onde o texto formatado vai ser escrito
- `size`: o tamanho total do buffer `str`, usado para o `snprintf` saber o limite que pode escrever sem ultrapassar o espaço reservado
- `format`: a string de formato, com os mesmos especificadores do `printf` (`%d`, `%f`, `%s`, `%x`, etc)
- `...`: os valores que vão substituir os especificadores em `format`

- Devolve a quantidade de caracteres que o texto completo teria, sem contar o `\0`, mesmo que ele não tenha cabido inteiro no buffer. Devolve um valor negativo se ocorrer erro de formatação
- Escreve no máximo `size - 1` caracteres, guardando sempre o último espaço do buffer para o `\0`, que é adicionado sempre que `size` for maior que `0`
- Se o retorno for maior ou igual a `size`, o texto foi cortado (truncado) para caber no buffer
- Com `str` igual a `NULL` e `size` igual a `0`, nada é escrito, mas o retorno informa quantos caracteres o texto precisaria, o que permite descobrir o tamanho exato antes de alocar o buffer

```c
char buf[32];
snprintf(buf, sizeof(buf), "%d", 42);           // "42"
snprintf(buf, sizeof(buf), "%.2f", 3.14159);    // "3.14"
snprintf(buf, sizeof(buf), "%x", 255);          // "ff"
snprintf(buf, sizeof(buf), "id=%d nome=%s", 7, "ana"); // "id=7 nome=ana"
```

Detectando quando o texto não coube no buffer:

```c
char buf[8];
int n = snprintf(buf, sizeof(buf), "%d", 123456789);
if (n >= (int)sizeof(buf)) {
  // buf contém "1234567" e o texto completo precisaria de 9 caracteres
}
```

Alocando exatamente o espaço necessário:

```c
int len = snprintf(NULL, 0, "%s-%d", "item", 1024); // 9
char *str = malloc(len + 1); // + 1 para o '\0'
snprintf(str, len + 1, "%s-%d", "item", 1024);  // "item-1024"
```

> Diferente do `sprintf`, que escreve sem saber o tamanho do buffer e pode causar um buffer overflow, o `snprintf` nunca passa do limite informado em `size`, sendo a forma segura de montar strings formatadas. É o caminho inverso do `atoi`/`strtol`, convertendo número em texto em vez de texto em número
