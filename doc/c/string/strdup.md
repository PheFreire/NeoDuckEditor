**strdup**

> `string.h`

O `strdup` cria uma cópia independente de uma string: ele aloca na heap um novo buffer do tamanho exato necessário, copia todo o conteúdo para lá, incluindo o `\0`, e devolve o ponteiro para essa cópia

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
char *strdup(const char *str);
```

- `str`: a string que será copiada

- Devolve um ponteiro para a nova string alocada, ou `NULL` se não houver memória suficiente para a alocação
- Equivale a fazer um `malloc(strlen(str) + 1)` seguido de um `strcpy`, mas em uma única chamada e sem o risco de esquecer o `+ 1` reservado para o `\0`
- A cópia é totalmente independente da original: alterar uma não afeta a outra, e a cópia continua válida mesmo depois que a original for liberada ou sair de escopo
- Útil para guardar um texto que vive em um buffer temporário, como um token devolvido pelo `strtok` ou uma linha lida com o `fgets`, que seria sobrescrita na próxima leitura
- Faz parte do POSIX há muito tempo e só entrou no padrão da linguagem a partir do C23, por isso em compiladores muito antigos ou com `-std=c99` estrito pode ser preciso declarar `_POSIX_C_SOURCE` para usá-lo

```c
char buffer[] = "pato";
char *copia = strdup(buffer);

if (copia == NULL) {
  // não foi possível alocar a cópia
}

copia[0] = 'g'; // copia == "gato", buffer continua "pato"

free(copia);
```

> Assim como toda alocação com `malloc`, a string devolvida pelo `strdup` precisa ser liberada com `free` quando não for mais usada, caso contrário ocorre um vazamento de memória
