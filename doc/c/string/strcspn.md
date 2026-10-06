**strcspn**

> `string.h`

O `strcspn` conta quantos caracteres do início de uma string **não** pertencem a um conjunto de caracteres informado. Em outras palavras, devolve o índice do primeiro caractere de `str` que aparece em `reject`, ou o tamanho da string se nenhum aparecer

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
size_t strcspn(const char *str, const char *reject);
```

- `str`: a string que será percorrida
- `reject`: o conjunto de caracteres procurados. A ordem não importa, cada caractere de `reject` é tratado individualmente, e não como uma substring

- Devolve a quantidade de caracteres do início de `str` que não estão em `reject`, que é o mesmo que o índice da primeira ocorrência de qualquer um deles
- Se nenhum caractere de `reject` aparecer em `str`, devolve `strlen(str)`, ou seja, o índice do `\0` final
- Não modifica nem copia nada, apenas percorre `str` e devolve um número
- O nome vem de "complementary span": o tamanho do trecho inicial formado pelo **complemento** do conjunto. O `strspn` faz o contrário, contando os caracteres que **pertencem** ao conjunto

```c
strcspn("pato,ganso", ",");     // 4: a vírgula está no índice 4
strcspn("pato ganso", " ,;");   // 4: o primeiro caractere do conjunto é o espaço
strcspn("pato", "xyz");         // 4: nenhum aparece, devolve strlen("pato")
strcspn(",pato", ",");          // 0: o primeiro caractere já está no conjunto
```

**Removendo o \n deixado pelo fgets**

O uso mais comum: o `fgets` guarda o `\n` do Enter no final da string, e o `strcspn` encontra a posição dele para trocá-lo por `\0`

```c
char nome[50];
if (fgets(nome, sizeof(nome), stdin) != NULL) {
  nome[strcspn(nome, "\n")] = '\0';
}
```

```text
nome = "pato\n\0"
         0123 4
strcspn(nome, "\n") → 4
nome[4] = '\0'      → "pato"
```

- Funciona também quando não há `\n` (a linha não coube no buffer, ou a entrada terminou sem quebra de linha): nesse caso o `strcspn` devolve a posição do `\0`, e a atribuição só reescreve o `\0` que já estava lá
- Por isso é mais seguro que `nome[strlen(nome) - 1] = '\0'`, que apaga o último caractere mesmo quando ele não é `\n`, e escreve fora do array se a string estiver vazia
- Para remover também o `\r` de arquivos vindos do Windows, use `"\r\n"` como conjunto

**Extraindo o primeiro campo de um texto**

```c
const char *linha = "chave=valor";
size_t tam = strcspn(linha, "=");   // 5

char chave[32];
snprintf(chave, sizeof(chave), "%.*s", (int)tam, linha);   // "chave"
const char *valor = linha + tam + 1;                       // "valor"
```

- Antes de usar `linha + tam + 1`, confira se `linha[tam]` não é `\0`, o que indicaria que o `=` não existe

> Diferente do `strtok`, o `strcspn` não altera a string e não guarda estado entre chamadas, então pode ser usado em strings constantes e em várias strings ao mesmo tempo. Diferente do `strstr`, que procura uma sequência exata, o `strcspn` procura **qualquer um** dos caracteres do conjunto
