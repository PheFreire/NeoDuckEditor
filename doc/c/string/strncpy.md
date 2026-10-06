**strncpy**

> `string.h`

O `strncpy` copia uma quantidade fixa de caracteres de uma string de origem para uma string de destino, funcionando de forma semelhante ao fatiamento de strings de outras linguagens (como `str[0:n]`), mas com comportamentos específicos de preenchimento e terminação que exigem atenção manual

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
char *strncpy(char *dest, const char *src, size_t n);
```

- `dest`: a string de destino, que deve ter espaço suficiente para receber os caracteres copiados
- `src`: a string de origem, de onde os caracteres serão copiados
- `n`: o número exato de caracteres a serem escritos em `dest`

- Devolve o próprio ponteiro `dest`
- Não garante o `\0` final: se os primeiros `n` caracteres de `src` não contiverem um `\0`, ele não é adicionado ao final de `dest`, e o resultado vira uma sequência de caracteres sem terminação, causando bugs se for tratada como string depois
- Se `src` for menor que `n` caracteres, o `strncpy` continua escrevendo `\0` em `dest` até completar os `n` bytes, o que pode ser um desperdício quando `n` é muito grande e `src` muito curta
- Somando um deslocamento ao ponteiro de `src` (aritmética de ponteiros), é possível copiar qualquer trecho do meio da string, como um `str[5:9]`

```c
char str[] = "Programacao";
char inicio[4]; // 3 caracteres + 1 para o '\0'
char meio[5];   // 4 caracteres + 1 para o '\0'

strncpy(inicio, str, 3);
inicio[3] = '\0'; // inicio == "Pro"

strncpy(meio, str + 5, 4); // str + 5 aponta para o 'a' de "amacao"
meio[4] = '\0'; // meio == "amac"
```

> Diferente do `fgets`, que sempre termina o buffer com `\0`, o `strncpy` deixa essa responsabilidade para quem chama, por isso depois de usá-lo para fatiar uma string é preciso escrever manualmente o `\0` na posição correta do destino
